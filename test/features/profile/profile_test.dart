// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:i18n_extension/i18n_extension.dart' show I18n;
import 'package:sizer/sizer.dart';

// Project imports:
import 'package:AppName/core/app/languages/data/localization.dart';
import 'package:AppName/features/catalog/domain/usecase/get_explore_data.dart';
import 'package:AppName/features/practice/domain/usecase/practice_usecases.dart';
import 'package:AppName/features/practice/presentation/cubit/practice_cubit.dart';
import 'package:AppName/features/profile/domain/entities/learner_profile.dart';
import 'package:AppName/features/profile/domain/usecase/profile_usecases.dart';
import 'package:AppName/features/profile/presentation/cubit/profile_cubit.dart';
import 'package:AppName/features/profile/presentation/screens/profile_screen.dart';
import '../../helpers/test_graph.dart';

void main() {
  late TestGraph graph;

  setUp(() async {
    graph = await TestGraph.create();
    await graph.profiles.save(
      ProfileFields(
        displayName: 'Lan',
        role: TargetRole.mobile,
        experience: ExperienceLevel.junior,
        techStack: const ['go', 'dart'],
        interviewDate: DateTime(2026, 12, 3),
      ),
    );
  });

  ProfileCubit newProfileCubit() => ProfileCubit(
        GetProfile(graph.profiles),
        GetAvatarPath(graph.profiles),
        GetExploreDashboard(graph.catalog),
        GetTracks(graph.catalog),
        ClearPracticeHistory(graph.practice),
        WatchProgress(graph.catalog),
      );

  Future<void> playOneSession() async {
    final cubit = PracticeCubit(
      StartPractice(graph.practice),
      ResumePractice(graph.practice),
      SavePractice(graph.practice),
      SubmitPractice(graph.practice),
    );
    await cubit.start('dart.set1');
    cubit.selectOption('a');
    await cubit.submit();
    await cubit.close();
  }

  test('loads the stack in pick order and learner stats', () async {
    await playOneSession();
    final cubit = newProfileCubit();
    await cubit.load();

    final state = cubit.state as ProfileLoaded;
    expect(state.profile?.displayName, 'Lan');
    expect(state.stack.map((t) => t.track.id), ['go', 'dart']);
    // dart.q1 correct (10) + dart.q2 self-check (5).
    expect(state.learner.xp, 15);
    await cubit.close();
  });

  test('reset clears history but keeps the profile', () async {
    await playOneSession();
    final cubit = newProfileCubit();
    await cubit.load();
    expect((cubit.state as ProfileLoaded).learner.practicedCount, 2);

    await cubit.resetProgress();
    await Future<void>.delayed(Duration.zero);

    final state = cubit.state as ProfileLoaded;
    expect(state.learner.practicedCount, 0);
    expect(state.learner.xp, 0);
    expect(state.profile?.displayName, 'Lan');
    expect(await graph.practice.getResults(), isEmpty);
    await cubit.close();
  });

  testWidgets('profile screen renders on a small screen at 1.3x text',
      (tester) async {
    late ProfileCubit cubit;
    await tester.runAsync(() async {
      cubit = newProfileCubit();
      await cubit.load();
    });

    await tester.binding.setSurfaceSize(const Size(320, 640));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      I18n(
        initialLocale: const Locale('vi', 'VN'),
        child: Sizer(
          builder: (context, orientation, deviceType) => MaterialApp(
            builder: (context, child) => MediaQuery(
              data: MediaQuery.of(context).copyWith(
                textScaler: const TextScaler.linear(1.3),
              ),
              child: child!,
            ),
            home: BlocProvider.value(
              value: cubit,
              child: const ProfileScreen(),
            ),
          ),
        ),
      ),
    );
    await tester.pump();

    expect(tester.takeException(), isNull);
    expect(find.text('Lan'), findsOneWidget);

    await tester.scrollUntilVisible(
      find.text(Strings.profileReset.i18n),
      300,
    );
    expect(tester.takeException(), isNull);
    await tester.tap(find.text(Strings.profileReset.i18n));
    await tester.pumpAndSettle();
    expect(find.text(Strings.profileResetTitle.i18n), findsOneWidget);
    await tester.tap(find.text(Strings.profileResetCancel.i18n));
    await tester.pumpAndSettle();

    await tester.pumpWidget(const SizedBox());
    await tester.runAsync(cubit.close);
  });
}
