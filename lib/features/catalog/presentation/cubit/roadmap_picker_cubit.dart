// Package imports:
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

// Project imports:
import 'package:interview_practice/features/catalog/domain/entities/track_overview.dart';
import 'package:interview_practice/features/catalog/domain/entities/user_roadmap.dart';
import 'package:interview_practice/features/catalog/domain/usecase/filter_tracks.dart';
import 'package:interview_practice/features/catalog/domain/usecase/get_explore_data.dart';
import 'package:interview_practice/features/catalog/domain/usecase/saved_tracks.dart';
import 'package:interview_practice/features/catalog/domain/usecase/user_roadmaps.dart';
import 'package:interview_practice/features/content/domain/entities/position.dart';
import 'package:interview_practice/features/content/domain/entities/question.dart';
import 'package:interview_practice/features/profile/domain/entities/learner_profile.dart';
import 'package:interview_practice/features/profile/domain/usecase/profile_usecases.dart';

part 'roadmap_picker_state.dart';

/// Picks a language (track) and a level to add a roadmap. Prefills from the
/// profile; nothing is saved until [confirm].
@injectable
class RoadmapPickerCubit extends Cubit<RoadmapPickerState> {
  final GetTracks _getTracks;
  final GetSavedTrackIds _getSavedTrackIds;
  final GetUserRoadmaps _getUserRoadmaps;
  final SuggestRoadmapLevel _suggestLevel;
  final GetProfile _getProfile;
  final AddUserRoadmap _addUserRoadmap;
  final GetPositions _getPositions;
  final AddPositionRoadmap _addPositionRoadmap;
  final FilterTracks _filterTracks = const FilterTracks();

  RoadmapPickerCubit(
    this._getTracks,
    this._getSavedTrackIds,
    this._getUserRoadmaps,
    this._suggestLevel,
    this._getProfile,
    this._addUserRoadmap,
    this._getPositions,
    this._addPositionRoadmap,
  ) : super(const RoadmapPickerLoading());

  /// [trackId] preselects a track, e.g. when coming from Explore.
  Future<void> load({String? trackId}) async {
    final tracks = (await _getTracks()).value ?? const <TrackOverview>[];
    final positions = (await _getPositions()).value ?? const <Position>[];
    if (isClosed) return;
    final suggestedPosition = _suggestPosition(positions);
    final available = {
      for (final overview in tracks)
        if (overview.track.isAvailable) overview.track.id,
    };
    final suggested = [
      if (trackId != null) trackId,
      ...?_getProfile()?.techStack,
    ].where(available.contains).firstOrNull;

    emit(
      RoadmapPickerLoaded(
        tracks: tracks,
        visibleTracks: tracks,
        savedTrackIds: _getSavedTrackIds().toSet(),
        roadmapIds: {for (final r in _getUserRoadmaps().roadmaps) r.id},
        selectedTrackId: suggested,
        level: _suggestLevel(),
        positions: positions,
        positionId: suggestedPosition?.id,
        optionId: _suggestOption(suggestedPosition)?.id,
      ),
    );
  }

  /// Position matching the profile's target role.
  Position? _suggestPosition(List<Position> positions) {
    final positionId = switch (_getProfile()?.role) {
      TargetRole.mobile => 'mobile',
      TargetRole.frontend => 'frontend',
      TargetRole.backend || TargetRole.fullstack => 'backend',
      null => null,
    };
    return positions.where((p) => p.id == positionId).firstOrNull ??
        positions.firstOrNull;
  }

  /// First option including a track of the profile's stack, else the first.
  PositionOption? _suggestOption(Position? position) {
    if (position == null) return null;
    final stack = _getProfile()?.techStack ?? const <String>[];
    return position.options
            .where((option) => option.trackIds.any(stack.contains))
            .firstOrNull ??
        position.options.firstOrNull;
  }

  void selectMode(RoadmapPickerMode mode) =>
      _update((s) => s.copyWith(mode: mode));

  void selectPosition(String positionId) => _update((s) {
        final position =
            s.positions.where((p) => p.id == positionId).firstOrNull;
        if (position == null) return s;
        return s.copyWith(
          positionId: positionId,
          optionId: _suggestOption(position)?.id,
        );
      });

  void selectOption(String optionId) =>
      _update((s) => s.copyWith(optionId: optionId));

  void search(String query) => _update(
        (s) => s.copyWith(
          query: query,
          visibleTracks: _filterTracks(s.tracks, s.category, query: query),
        ),
      );

  void selectCategory(String? category) => _update(
        (s) => s.copyWith(
          category: () => category,
          visibleTracks: _filterTracks(s.tracks, category, query: s.query),
        ),
      );

  /// Unavailable tracks cannot be picked.
  void selectTrack(String trackId) => _update((s) {
        final available = s.tracks.any(
          (overview) =>
              overview.track.id == trackId && overview.track.isAvailable,
        );
        return available ? s.copyWith(selectedTrackId: trackId) : s;
      });

  void selectLevel(QuestionLevel level) =>
      _update((s) => s.copyWith(level: level));

  /// Adds (or reopens) the roadmap and makes it the active one.
  Future<void> confirm() async {
    final current = state;
    if (current is! RoadmapPickerLoaded || !current.canConfirm) return;
    emit(current.copyWith(saving: true));
    switch (current.mode) {
      case RoadmapPickerMode.language:
        await _addUserRoadmap(current.selectedTrackId!, current.level);
      case RoadmapPickerMode.position:
        await _addPositionRoadmap(
          current.positionId!,
          current.optionId!,
          current.level,
        );
    }
    final latest = state;
    if (!isClosed && latest is RoadmapPickerLoaded) {
      emit(latest.copyWith(saving: false, done: true));
    }
  }

  void _update(RoadmapPickerLoaded Function(RoadmapPickerLoaded s) change) {
    final current = state;
    if (current is RoadmapPickerLoaded && !current.saving) {
      emit(change(current));
    }
  }
}
