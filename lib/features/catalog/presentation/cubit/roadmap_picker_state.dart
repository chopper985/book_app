part of 'roadmap_picker_cubit.dart';

enum RoadmapPickerMode { language, position }

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
  final RoadmapPickerMode mode;
  final List<Position> positions;
  final String? positionId;
  final String? optionId;

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
    this.mode = RoadmapPickerMode.language,
    this.positions = const [],
    this.positionId,
    this.optionId,
  });

  Position? get position =>
      positions.where((p) => p.id == positionId).firstOrNull;

  PositionOption? get option => position?.optionById(optionId ?? '');

  /// Names of every track the picked position option includes.
  List<String> get positionTrackIds => switch ((position, option)) {
        (final position?, final option?) => position.trackIdsFor(option),
        _ => const [],
      };

  bool get canConfirm =>
      !saving &&
      !done &&
      switch (mode) {
        RoadmapPickerMode.language => selectedTrackId != null,
        RoadmapPickerMode.position => option != null,
      };

  /// The picked roadmap is already one of the learner's roadmaps.
  bool get isExisting => switch (mode) {
        RoadmapPickerMode.language => selectedTrackId != null &&
            roadmapIds.contains(UserRoadmap.idOf(selectedTrackId!, level)),
        RoadmapPickerMode.position => option != null &&
            roadmapIds.contains(
              UserRoadmap.positionIdOf(positionId!, optionId!, level),
            ),
      };

  RoadmapPickerLoaded copyWith({
    List<TrackOverview>? visibleTracks,
    String? Function()? category,
    String? query,
    String? selectedTrackId,
    QuestionLevel? level,
    bool? saving,
    bool? done,
    RoadmapPickerMode? mode,
    String? positionId,
    String? optionId,
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
      mode: mode ?? this.mode,
      positions: positions,
      positionId: positionId ?? this.positionId,
      optionId: optionId ?? this.optionId,
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
        mode,
        positions,
        positionId,
        optionId,
      ];
}
