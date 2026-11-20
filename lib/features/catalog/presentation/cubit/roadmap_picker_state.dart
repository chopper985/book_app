part of 'roadmap_picker_cubit.dart';

sealed class RoadmapPickerState extends Equatable {
  const RoadmapPickerState();

  @override
  List<Object?> get props => [];
}

final class RoadmapPickerLoading extends RoadmapPickerState {
  const RoadmapPickerLoading();
}

final class RoadmapPickerLoaded extends RoadmapPickerState {
  final List<TrackOverview> tracks;

  /// [tracks] after the category and search filters.
  final List<TrackOverview> visibleTracks;
  final Set<String> savedTrackIds;

  /// Ids of the roadmaps the learner already follows.
  final Set<String> roadmapIds;
  final String? category;
  final String query;
  final String? selectedTrackId;
  final QuestionLevel level;
  final bool saving;
  final bool done;

  const RoadmapPickerLoaded({
    required this.tracks,
    required this.visibleTracks,
    required this.savedTrackIds,
    required this.roadmapIds,
    required this.level,
    this.category,
    this.query = '',
    this.selectedTrackId,
    this.saving = false,
    this.done = false,
  });

  bool get canConfirm => selectedTrackId != null && !saving && !done;

  /// The picked track + level is already one of the learner's roadmaps.
  bool get isExisting =>
      selectedTrackId != null &&
      roadmapIds.contains(UserRoadmap.idOf(selectedTrackId!, level));

  RoadmapPickerLoaded copyWith({
    List<TrackOverview>? visibleTracks,
    String? Function()? category,
    String? query,
    String? selectedTrackId,
    QuestionLevel? level,
    bool? saving,
    bool? done,
  }) {
    return RoadmapPickerLoaded(
      tracks: tracks,
      visibleTracks: visibleTracks ?? this.visibleTracks,
      savedTrackIds: savedTrackIds,
      roadmapIds: roadmapIds,
      category: category == null ? this.category : category(),
      query: query ?? this.query,
      selectedTrackId: selectedTrackId ?? this.selectedTrackId,
      level: level ?? this.level,
      saving: saving ?? this.saving,
      done: done ?? this.done,
    );
  }

  @override
  List<Object?> get props => [
        tracks,
        visibleTracks,
        savedTrackIds,
        roadmapIds,
        category,
        query,
        selectedTrackId,
        level,
        saving,
        done,
      ];
}
