// Package imports:
import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';

// Project imports:
import 'package:interview_practice/features/auth/domain/entities/auth_failure.dart';
import 'package:interview_practice/features/auth/domain/entities/auth_results.dart';
import 'package:interview_practice/features/auth/domain/entities/auth_user.dart';
import 'package:interview_practice/features/auth/domain/usecase/account_usecases.dart';
import 'package:interview_practice/features/auth/domain/usecase/normalize_phone_number.dart';
import 'package:interview_practice/features/auth/presentation/cubit/sign_in_cubit.dart';
import 'package:interview_practice/features/catalog/domain/entities/user_roadmap.dart';
import 'package:interview_practice/features/content/domain/entities/question.dart';
import 'package:interview_practice/features/practice/domain/entities/session_result.dart';
import 'package:interview_practice/features/practice/domain/usecase/practice_usecases.dart';
import 'package:interview_practice/features/practice/presentation/cubit/practice_cubit.dart';
import 'package:interview_practice/features/profile/domain/entities/learner_profile.dart';
import 'package:interview_practice/features/sync/domain/entities/learner_snapshot.dart';
import 'package:interview_practice/features/sync/domain/usecase/learner_sync.dart';
import 'package:interview_practice/features/sync/domain/usecase/merge_snapshots.dart';
import '../../helpers/fake_auth_repository.dart';
import '../../helpers/open_practice_gate.dart';
import '../../helpers/test_graph.dart';

SessionResult result(String id, DateTime at) => SessionResult(
      sessionId: id,
      setId: 'dart.set1',
      trackId: 'dart',
      startedAt: at,
      submittedAt: at,
      items: const [
        QuestionResult(
          questionId: 'dart.q1',
          contentVersion: 1,
          status: AnswerStatus.correct,
        ),
      ],
    );

LearnerProfile profile(String name, DateTime updatedAt, {String? avatar}) =>
    LearnerProfile(
      fields: ProfileFields(
        displayName: name,
        role: TargetRole.mobile,
        experience: ExperienceLevel.junior,
        techStack: const ['dart'],
        avatarFileName: avatar,
      ),
      createdAt: DateTime(2026, 11),
      updatedAt: updatedAt,
    );

UserRoadmap roadmap(String trackId) => UserRoadmap(
      trackId: trackId,
      level: QuestionLevel.junior,
      addedAt: DateTime(2026, 11),
    );

void main() {
  group('NormalizePhoneNumber', () {
    const normalize = NormalizePhoneNumber();

    test('Vietnamese numbers in common forms', () {
      expect(normalize('0912 345 678'), '+84912345678');
      expect(normalize('912345678'), '+84912345678');
      expect(normalize('+84 912-345-678'), '+84912345678');
      expect(normalize('84912345678'), '+84912345678');
      expect(normalize('0084912345678'), '+84912345678');
    });

    test('other countries with a + prefix', () {
      expect(normalize('+1 (650) 555-1234'), '+16505551234');
    });

    test('rejects what cannot be a phone number', () {
      expect(normalize(''), isNull);
      expect(normalize('12345'), isNull);
      expect(normalize('0912abc678'), isNull);
      expect(normalize('+1234567890123456'), isNull);
    });
  });

  group('MergeSnapshots', () {
    const merge = MergeSnapshots();

    test('no cloud copy keeps the device data', () {
      final local = LearnerSnapshot(results: [result('a', DateTime(2026))]);
      expect(merge(local, null), local);
    });

    test('unions results and lists, newest profile wins', () {
      final local = LearnerSnapshot(
        profile: profile('Lan', DateTime(2026, 11, 2), avatar: 'me.jpg'),
        results: [result('a', DateTime(2026, 11, 2))],
        roadmaps: [roadmap('dart')],
        activeRoadmapId: 'dart:junior',
        savedTrackIds: const ['dart'],
      );
      final remote = LearnerSnapshot(
        profile: profile('Lan Anh', DateTime(2026, 11, 5)),
        results: [
          result('b', DateTime(2026, 10, 30)),
          result('a', DateTime(2026, 11, 2)),
        ],
        roadmaps: [roadmap('go'), roadmap('dart')],
        activeRoadmapId: 'go:junior',
        savedTrackIds: const ['go', 'dart'],
      );
      final merged = merge(local, remote);

      expect(merged.results.map((r) => r.sessionId), ['b', 'a']);
      expect(merged.profile?.displayName, 'Lan Anh');
      expect(
        merged.profile?.avatarFileName,
        'me.jpg',
        reason: 'images are not synced; the device keeps its avatar',
      );
      expect(merged.roadmaps.map((r) => r.id), ['dart:junior', 'go:junior']);
      expect(merged.activeRoadmapId, 'dart:junior');
      expect(merged.savedTrackIds, ['dart', 'go']);
    });

    test('an older cloud profile does not overwrite the device', () {
      final merged = merge(
        LearnerSnapshot(profile: profile('Lan', DateTime(2026, 11, 5))),
        LearnerSnapshot(profile: profile('Old', DateTime(2026, 10, 30))),
      );
      expect(merged.profile?.displayName, 'Lan');
    });
  });

  group('LearnerSync', () {
    late TestGraph graph;

    setUp(() async {
      graph = await TestGraph.create();
      graph.sync.start();
    });

    tearDown(() => graph.sync.dispose());

    Future<void> practiceOnce() async {
      final cubit = PracticeCubit(
        StartPractice(graph.practice, const OpenPracticeGate()),
        ResumePractice(graph.practice),
        SavePractice(graph.practice),
        SubmitPractice(graph.practice),
      );
      await cubit.start('dart.set1');
      cubit.selectOption('a');
      await cubit.submit();
      await cubit.close();
    }

    /// Lets the chained awaits of a sync (fetch, merge, push) complete.
    Future<void> settle() async {
      for (var i = 0; i < 20; i++) {
        await Future<void>.delayed(Duration.zero);
      }
    }

    test('anonymous accounts are not synced', () async {
      await practiceOnce();
      graph.auth.emitUser(anonymousUser);
      await settle();
      expect(graph.sync.syncingUid, isNull);
      expect(graph.cloud.pushes, 0);
    });

    test('linking merges the cloud copy both ways', () async {
      await practiceOnce();
      graph.cloud.stored['user-1'] = LearnerSnapshot(
        profile: profile('Cloud Lan', DateTime(2027)),
        results: [result('from-phone', DateTime(2026, 10, 30))],
        roadmaps: [roadmap('dart')],
        activeRoadmapId: 'dart:junior',
        savedTrackIds: const ['dart'],
      );

      graph.auth.emitUser(googleUser);
      await settle();
      await settle();

      expect(graph.sync.syncingUid, 'user-1');
      final local = await graph.practice.getResults();
      expect(local.map((r) => r.sessionId), contains('from-phone'));
      expect(graph.profiles.profile?.displayName, 'Cloud Lan');
      expect(graph.roadmaps.active?.id, 'dart:junior');
      expect(graph.saved.savedTrackIds, ['dart']);
      expect(graph.cloud.stored['user-1']!.results, hasLength(2));
      expect(
        graph.cloud.uploadedResultIds,
        hasLength(1),
        reason: 'only the device result is uploaded',
      );
    });

    test('local changes are pushed after the debounce', () async {
      // A sync started inside fakeAsync, so its timers use the fake clock.
      await graph.sync.dispose();
      fakeAsync((async) {
        final sync = LearnerSync(
          graph.auth,
          graph.cloud,
          graph.practice,
          graph.profiles,
          graph.saved,
          graph.roadmaps,
          graph.usage,
        )..start();
        graph.auth.emitUser(googleUser);
        // Finish the initial merge (it waits one timer tick) before counting.
        async.elapse(const Duration(milliseconds: 10));
        final before = graph.cloud.pushes;
        expect(before, 1, reason: 'the initial merge pushed once');

        graph.saved.toggle('dart');
        async.flushMicrotasks();
        async.elapse(const Duration(seconds: 1));
        expect(graph.cloud.pushes, before, reason: 'still debouncing');

        graph.saved.toggle('go');
        async.flushMicrotasks();
        async.elapse(LearnerSync.debounce);
        async.flushMicrotasks();
        expect(graph.cloud.pushes, before + 1, reason: 'one push for both');
        expect(graph.cloud.stored['user-1']!.savedTrackIds, ['go', 'dart']);
        sync.dispose();
        async.flushMicrotasks();
      });
    });

    test('progress reset also clears the cloud results', () async {
      await practiceOnce();
      graph.auth.emitUser(googleUser);
      await settle();
      expect(graph.cloud.stored['user-1']!.results, isNotEmpty);

      await ResetProgressEverywhere(graph.practice, graph.sync)();
      expect(graph.cloud.stored['user-1']!.results, isEmpty);
      expect(await graph.practice.getResults(), isEmpty);
    });

    test('sign-out uploads, then clears the device', () async {
      await graph.profiles.save(profile('Lan', DateTime(2026)).fields);
      graph.auth.emitUser(googleUser);
      await settle();
      await practiceOnce();
      await graph.saved.toggle('dart');

      await SignOut(
        graph.auth,
        graph.sync,
        ClearLocalLearnerData(
          graph.practice,
          graph.profiles,
          graph.saved,
          graph.roadmaps,
          graph.usage,
        ),
      )();

      expect(graph.cloud.stored['user-1']!.results, hasLength(1));
      expect(graph.cloud.stored['user-1']!.savedTrackIds, ['dart']);
      expect(graph.profiles.profile, isNull, reason: 'back to onboarding');
      expect(await graph.practice.getResults(), isEmpty);
      expect(graph.saved.savedTrackIds, isEmpty);
      expect(graph.auth.currentUser, anonymousUser);
      expect(graph.sync.syncingUid, isNull);
    });

    group('delete account', () {
      DeleteAccount deleteAccount() => DeleteAccount(
            graph.auth,
            graph.sync,
            ClearLocalLearnerData(
              graph.practice,
              graph.profiles,
              graph.saved,
              graph.roadmaps,
              graph.usage,
            ),
          );

      test('removes cloud and device data', () async {
        await graph.profiles.save(profile('Lan', DateTime(2026)).fields);
        graph.auth.emitUser(googleUser);
        await settle();

        expect(await deleteAccount()(), isNull);
        expect(graph.cloud.stored.containsKey('user-1'), isFalse);
        expect(graph.profiles.profile, isNull);
      });

      test('needing a fresh sign-in keeps everything', () async {
        await graph.profiles.save(profile('Lan', DateTime(2026)).fields);
        graph.auth.emitUser(googleUser);
        await settle();
        graph.auth.deleteFailure =
            AuthFailure(AuthFailureCode.requiresRecentLogin);

        final failure = await deleteAccount()();
        expect(failure?.code, AuthFailureCode.requiresRecentLogin);
        expect(graph.profiles.profile, isNotNull);
        expect(
          graph.cloud.stored['user-1']?.profile,
          isNotNull,
          reason: 'cloud copy restored',
        );
      });
    });
  });

  group('SignInCubit', () {
    late FakeAuthRepository auth;

    setUp(() => auth = FakeAuthRepository());

    SignInCubit newCubit() => SignInCubit(
          SignInWithGoogle(auth),
          SignInWithFacebook(auth),
          RequestPhoneCode(auth),
          ConfirmPhoneCode(auth),
        );

    test('google success, cancel and failure', () async {
      var cubit = newCubit();
      await cubit.signInWithGoogle();
      expect(cubit.state.done, isTrue);

      auth.googleResult = const SignInCancelled();
      cubit = newCubit();
      await cubit.signInWithGoogle();
      expect(cubit.state.done, isFalse);
      expect(cubit.state.failure, isNull);

      auth.googleResult =
          SignInFailed(AuthFailure(AuthFailureCode.notConfigured));
      await cubit.signInWithGoogle();
      expect(cubit.state.failure?.code, AuthFailureCode.notConfigured);
    });

    test('facebook success links the account; cancel keeps the screen',
        () async {
      var cubit = newCubit();
      await cubit.signInWithFacebook();
      expect(cubit.state.done, isTrue);
      expect(auth.currentUser?.isLinked, isTrue);
      expect(auth.currentUser?.providers, {AuthProviderKind.facebook});

      auth.facebookResult = const SignInCancelled();
      cubit = newCubit();
      await cubit.signInWithFacebook();
      expect(cubit.state.done, isFalse);
      expect(cubit.state.busy, isFalse);
      expect(cubit.state.failure, isNull);

      auth.facebookResult = SignInFailed(
        AuthFailure(AuthFailureCode.accountExistsWithOtherProvider),
      );
      await cubit.signInWithFacebook();
      expect(
        cubit.state.failure?.code,
        AuthFailureCode.accountExistsWithOtherProvider,
      );
    });

    test('phone flow: normalized number, countdown, code, done', () {
      fakeAsync((async) {
        final cubit = newCubit();
        cubit.setPhone('0912 345 678');
        cubit.sendCode();
        async.flushMicrotasks();

        expect(auth.calls.last, 'code +84912345678');
        expect(cubit.state.step, SignInStep.code);
        expect(cubit.state.resendSeconds, SignInCubit.resendDelaySeconds);
        expect(cubit.state.canResend, isFalse);

        async.elapse(const Duration(seconds: SignInCubit.resendDelaySeconds));
        expect(cubit.state.canResend, isTrue);

        auth.confirmResult =
            SignInFailed(AuthFailure(AuthFailureCode.invalidCode));
        cubit.setCode('111111');
        async.flushMicrotasks();
        expect(cubit.state.failure?.code, AuthFailureCode.invalidCode);
        expect(cubit.state.done, isFalse);

        auth.confirmResult = const SignInSuccess(googleUser);
        cubit.setCode('123456');
        async.flushMicrotasks();
        expect(auth.calls.last, 'confirm verification-1 123456');
        expect(cubit.state.done, isTrue);
        cubit.close();
      });
    });

    test('invalid phone never reaches Firebase', () async {
      final cubit = newCubit();
      cubit.setPhone('12345');
      await cubit.sendCode();
      expect(cubit.state.failure?.code, AuthFailureCode.invalidPhoneNumber);
      expect(auth.calls, isEmpty);
      expect(cubit.state.step, SignInStep.phone);
    });

    test('auto-verified SMS signs in without a code', () async {
      auth.codeRequest = const PhoneAutoVerified(SignInSuccess(googleUser));
      final cubit = newCubit();
      cubit.setPhone('0912345678');
      await cubit.sendCode();
      expect(cubit.state.done, isTrue);
    });
  });
}
