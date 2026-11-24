// Package imports:
import 'package:flutter_test/flutter_test.dart';

// Project imports:
import 'package:interview_practice/features/auth/domain/entities/auth_results.dart';
import 'package:interview_practice/features/auth/domain/usecase/account_usecases.dart';
import 'package:interview_practice/features/auth/presentation/cubit/sign_in_cubit.dart';
import 'package:interview_practice/features/catalog/domain/entities/user_roadmap.dart';
import 'package:interview_practice/features/content/domain/entities/question.dart';
import 'package:interview_practice/features/practice/domain/entities/session_result.dart';
import 'package:interview_practice/features/profile/domain/entities/learner_profile.dart';
import 'package:interview_practice/features/sync/domain/entities/learner_snapshot.dart';
import 'package:interview_practice/features/sync/domain/usecase/merge_snapshots.dart';
import '../../helpers/fake_auth_repository.dart';
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
  // The account's real profile is older than the guest's fresh onboarding.
  final cloud = LearnerSnapshot(
    profile: profile('Lan (account)', DateTime(2026, 9)),
    results: [result('account-1', DateTime(2026, 9, 2))],
    roadmaps: [roadmap('flutter')],
    activeRoadmapId: 'flutter:junior',
    savedTrackIds: const ['flutter'],
  );
  final guest = LearnerSnapshot(
    profile: profile('Guest', DateTime(2026, 11, 25), avatar: 'me.jpg'),
    results: [result('guest-1', DateTime(2026, 11, 25))],
    roadmaps: [roadmap('dart')],
    activeRoadmapId: 'dart:junior',
    savedTrackIds: const ['dart'],
  );

  group('MergeSnapshots.adoptAccount', () {
    const merge = MergeSnapshots();

    test('the account profile wins and keeps the device avatar', () {
      final merged = merge.adoptAccount(guest, cloud, keepGuestProgress: true);
      expect(merged.profile?.displayName, 'Lan (account)');
      expect(merged.profile?.avatarFileName, 'me.jpg');
      expect(merged.profile?.updatedAt, DateTime(2026, 9));
    });

    test('keeping guest progress adds it after the account data', () {
      final merged = merge.adoptAccount(guest, cloud, keepGuestProgress: true);
      expect(merged.resultIds, {'account-1', 'guest-1'});
      expect(
        merged.roadmaps.map((r) => r.id),
        ['flutter:junior', 'dart:junior'],
      );
      expect(merged.activeRoadmapId, 'flutter:junior');
      expect(merged.savedTrackIds, ['flutter', 'dart']);
    });

    test('dropping guest progress keeps only the account data', () {
      final merged = merge.adoptAccount(guest, cloud, keepGuestProgress: false);
      expect(merged.resultIds, {'account-1'});
      expect(merged.roadmaps.map((r) => r.id), ['flutter:junior']);
      expect(merged.savedTrackIds, ['flutter']);
    });

    test('an account without roadmaps keeps the onboarding ones', () {
      final empty = LearnerSnapshot(profile: cloud.profile);
      final merged = merge.adoptAccount(guest, empty, keepGuestProgress: false);
      expect(merged.roadmaps.map((r) => r.id), ['dart:junior']);
      expect(merged.activeRoadmapId, 'dart:junior');
      expect(merged.results, isEmpty);
    });
  });

  group('LearnerSync, guest signs in to an existing account', () {
    late TestGraph graph;

    setUp(() async {
      graph = await TestGraph.create();
      graph.sync.start();
      graph.cloud.stored[googleUser.uid] = cloud;
      await graph.profiles.restore(guest.profile);
      await graph.roadmaps.replaceAll(guest.roadmaps, guest.activeRoadmapId);
      graph.auth.emitUser(anonymousUser);
    });

    tearDown(() => graph.sync.dispose());

    Future<void> settle() async {
      for (var i = 0; i < 40; i++) {
        await Future<void>.delayed(Duration.zero);
      }
    }

    test('no guest practice: account data is used without asking', () async {
      graph.auth.emitUser(googleUser);
      final prompt = await graph.sync.guestDataPrompt(googleUser.uid);
      await settle();

      expect(prompt, isNull);
      expect(graph.profiles.profile?.displayName, 'Lan (account)');
      expect(
        (await graph.practice.getResults()).map((r) => r.sessionId),
        ['account-1'],
      );
      expect(graph.roadmaps.active?.id, 'flutter:junior');
    });

    test('guest practice is merged when the learner agrees', () async {
      await graph.practice.importResults(guest.results);
      graph.auth.emitUser(googleUser);
      final prompt = await graph.sync.guestDataPrompt(googleUser.uid);
      expect(prompt?.sessions, 1);

      prompt!.resolve(keepGuestProgress: true);
      await settle();
      expect(
        (await graph.practice.getResults()).map((r) => r.sessionId).toSet(),
        {'account-1', 'guest-1'},
      );
      expect(graph.cloud.stored[googleUser.uid]!.resultIds, {
        'account-1',
        'guest-1',
      });
      expect(graph.profiles.profile?.displayName, 'Lan (account)');
    });

    test('guest practice is dropped when the learner declines', () async {
      await graph.practice.importResults(guest.results);
      graph.auth.emitUser(googleUser);
      final prompt = await graph.sync.guestDataPrompt(googleUser.uid);

      prompt!.resolve(keepGuestProgress: false);
      await settle();
      expect(
        (await graph.practice.getResults()).map((r) => r.sessionId),
        ['account-1'],
      );
      expect(graph.cloud.stored[googleUser.uid]!.resultIds, {'account-1'});
      expect(graph.roadmaps.roadmaps.map((r) => r.id), ['flutter:junior']);
    });
  });

  group('SignInCubit asks about guest data', () {
    late TestGraph graph;

    setUp(() async {
      graph = await TestGraph.create();
      graph.sync.start();
      graph.cloud.stored[googleUser.uid] = cloud;
      await graph.practice.importResults(guest.results);
      graph.auth.emitUser(anonymousUser);
      graph.auth.googleResult =
          const SignInSuccess(googleUser, switchedAccount: true);
    });

    tearDown(() => graph.sync.dispose());

    SignInCubit newCubit() => SignInCubit(
          SignInWithGoogle(graph.auth),
          SignInWithFacebook(graph.auth),
          RequestPhoneCode(graph.auth),
          ConfirmPhoneCode(graph.auth),
          graph.sync,
        );

    test('a switched account with guest practice waits for the answer',
        () async {
      final cubit = newCubit();
      await cubit.signInWithGoogle();
      expect(cubit.state.guestSessions, 1);
      expect(cubit.state.done, isFalse);
      expect(cubit.state.busy, isFalse);

      await cubit.resolveGuestData(keepGuestProgress: false);
      expect(cubit.state.done, isTrue);
      expect(cubit.state.guestSessions, isNull);
      await cubit.close();
    });

    test('closing without an answer keeps the guest progress', () async {
      final cubit = newCubit();
      await cubit.signInWithGoogle();
      expect(cubit.state.guestSessions, 1);
      await cubit.close();
      for (var i = 0; i < 40; i++) {
        await Future<void>.delayed(Duration.zero);
      }
      expect(graph.cloud.stored[googleUser.uid]!.resultIds, {
        'account-1',
        'guest-1',
      });
    });

    test('a linked (same) account finishes right away', () async {
      graph.auth.googleResult = const SignInSuccess(googleUser);
      final cubit = newCubit();
      await cubit.signInWithGoogle();
      expect(cubit.state.done, isTrue);
      expect(cubit.state.guestSessions, isNull);
      await cubit.close();
    });
  });
}
