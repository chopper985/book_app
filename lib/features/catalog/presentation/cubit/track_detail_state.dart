part of 'track_detail_cubit.dart';

sealed class TrackDetailState extends Equatable {
  const TrackDetailState();

  @override
  List<Object?> get props => [];
}

final class TrackDetailLoading extends TrackDetailState {
  const TrackDetailLoading();
}

final class TrackDetailLoaded extends TrackDetailState {
  final TrackDetail detail;
  final String? topicId;
  final QuestionLevel? level;
  final List<QuizSetSummary> visibleSets;

  const TrackDetailLoaded({
    required this.detail,
    required this.visibleSets,
    this.topicId,
    this.level,
  });

  @override
  List<Object?> get props => [detail, topicId, level, visibleSets];
}

final class TrackDetailNotFound extends TrackDetailState {
  const TrackDetailNotFound();
}

final class TrackDetailInvalidContent extends TrackDetailState {
  final List<ContentIssue> issues;

  const TrackDetailInvalidContent(this.issues);

  @override
  List<Object?> get props => [issues];
}
