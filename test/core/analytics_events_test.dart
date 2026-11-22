// Package imports:
import 'package:flutter_test/flutter_test.dart';

// Project imports:
import 'package:interview_practice/core/analytics/app_analytics.dart';
import 'package:interview_practice/features/catalog/domain/usecase/get_explore_data.dart';
import 'package:interview_practice/features/catalog/domain/usecase/get_track_detail.dart';
import 'package:interview_practice/features/catalog/domain/usecase/saved_tracks.dart';
import 'package:interview_practice/features/catalog/presentation/cubit/track_detail_cubit.dart';
import 'package:interview_practice/features/practice/domain/usecase/practice_usecases.dart';
import 'package:interview_practice/features/practice/presentation/cubit/practice_cubit.dart';
import 'package:interview_practice/features/profile/domain/entities/learner_profile.dart';
import 'package:interview_practice/features/profile/domain/usecase/profile_usecases.dart';
import 'package:interview_practice/features/profile/presentation/cubit/onboarding_cubit.dart';
import '../helpers/open_practice_gate.dart';
import '../helpers/test_graph.dart';

/// Records every call as `name {params}`.
class RecordingAnalytics extends NoopAppAnalytics {
  final List<String> events = [];
  final Map<String, String?> userProperties = {};

  @override
  Future<void> onboardingCompleted({
    required String role,
    required String experience,
    required int stackSize,
    required bool hasInterviewDate,
  }) async =>
      events.add('onboarding_completed $role $experience $stackSize '
          '$hasInterviewDate');

  @override
  Future<void> practiceStarted({
    required String trackId,
    required String setId,
    required PracticeMode mode,
    required int questionCount,
  }) async =>
      events.add('practice_started $setId ${mode.name} $questionCount');

  @override
  Future<void> practiceSubmitted({
    required String trackId,
    required String setId,
    required int scorePercent,
    required int questionCount,
    required int durationSeconds,
    required bool timedOut,
  }) async =>
      events.add('practice_submitted $setId $scorePercent $questionCount '
          '$durationSeconds $timedOut');

  @override
  Future<void> trackSaved({
    required String trackId,
    required bool saved,
  }) async =>
      events.add('track_saved $trackId $saved');

  @override
  Future<void> setUserProperty(String name, String? value) async =>
      userProperties[name] = value;
}

void main() {
  late TestGraph graph;
  late RecordingAnalytics analytics;

  setUp(() async {
    graph = await TestGraph.create();
    analytics = RecordingAnalytics();
  });

  PracticeCubit newPractice() => PracticeCubit(
        StartPractice(graph.practice, const OpenPracticeGate()),
        ResumePractice(graph.practice),
        SavePractice(graph.practice),
        SubmitPractice(graph.practice),
        analytics: analytics,
      );

  test('practice logs start mode and the graded result', () async {
    var cubit = newPractice();
    await cubit.start('dart.set1');
    final id = (cubit.state as PracticeInProgress).bundle.session.id;
    await cubit.close();

    cubit = newPractice();
    await cubit.start('dart.set1', sessionId: id);
    cubit.selectOption('a');
    graph.clock.value = graph.clock.value.add(const Duration(seconds: 90));
    await cubit.submit();
    await cubit.close();

    cubit = newPractice();
    await cubit.start('dart.set1', onlyQuestionIds: ['dart.q1']);
    await cubit.close();

    expect(analytics.events, [
      'practice_started dart.set1 full 2',
      'practice_started dart.set1 resume 2',
      // q1 correct; q2 self-explain is not graded: 100%.
      'practice_submitted dart.set1 100 2 90 false',
      'practice_started dart.set1 subset 1',
    ]);
  });

  test('onboarding logs completion and sets user properties', () async {
    final cubit = OnboardingCubit(
      GetTracks(graph.catalog),
      SaveProfile(graph.profiles),
      analytics: analytics,
    );
    cubit.setName('Lan');
    await cubit.next();
    cubit.selectRole(TargetRole.backend);
    await cubit.next();
    cubit.selectExperience(ExperienceLevel.fresher);
    await cubit.next();
    cubit.toggleTrack('dart');
    await cubit.next();
    await cubit.close();

    expect(analytics.events, ['onboarding_completed backend fresher 1 false']);
    expect(analytics.userProperties, {
      'role': 'backend',
      'experience': 'fresher',
    });
  });

  test('bookmark logs saved then unsaved', () async {
    final cubit = TrackDetailCubit(
      GetTrackDetail(graph.catalog),
      ToggleSavedTrack(graph.saved),
      WatchProgress(graph.catalog),
      analytics: analytics,
    );
    await cubit.load('dart');
    await cubit.toggleSaved();
    await Future<void>.delayed(Duration.zero);
    await cubit.toggleSaved();
    await cubit.close();

    expect(analytics.events, [
      'track_saved dart true',
      'track_saved dart false',
    ]);
  });
}
