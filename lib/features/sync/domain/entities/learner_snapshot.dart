// Package imports:
import 'package:equatable/equatable.dart';

// Project imports:
import 'package:interview_practice/features/catalog/domain/entities/user_roadmap.dart';
import 'package:interview_practice/features/practice/domain/entities/session_result.dart';
import 'package:interview_practice/features/profile/domain/entities/learner_profile.dart';

/// Everything that follows a signed-in learner across devices. Unfinished
/// sessions and the avatar image stay on the device.
class LearnerSnapshot extends Equatable {
  final LearnerProfile? profile;
  final List<SessionResult> results;

  /// Most recently selected first.
  final List<UserRoadmap> roadmaps;
  final String? activeRoadmapId;
  final List<String> savedTrackIds;

  const LearnerSnapshot({
    this.profile,
    this.results = const [],
    this.roadmaps = const [],
    this.activeRoadmapId,
    this.savedTrackIds = const [],
  });

  static const LearnerSnapshot empty = LearnerSnapshot();

  Set<String> get resultIds => {for (final r in results) r.sessionId};

  @override
  List<Object?> get props =>
      [profile, results, roadmaps, activeRoadmapId, savedTrackIds];
}
