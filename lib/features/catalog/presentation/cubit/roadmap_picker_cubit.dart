// Package imports:
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

// Project imports:
import 'package:AppName/features/catalog/domain/entities/track_overview.dart';
import 'package:AppName/features/catalog/domain/entities/user_roadmap.dart';
import 'package:AppName/features/catalog/domain/usecase/filter_tracks.dart';
import 'package:AppName/features/catalog/domain/usecase/get_explore_data.dart';
import 'package:AppName/features/catalog/domain/usecase/saved_tracks.dart';
import 'package:AppName/features/catalog/domain/usecase/user_roadmaps.dart';
import 'package:AppName/features/content/domain/entities/question.dart';
import 'package:AppName/features/profile/domain/usecase/profile_usecases.dart';

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
  final FilterTracks _filterTracks = const FilterTracks();

  RoadmapPickerCubit(
    this._getTracks,
    this._getSavedTrackIds,
    this._getUserRoadmaps,
    this._suggestLevel,
    this._getProfile,
    this._addUserRoadmap,
  ) : super(const RoadmapPickerLoading());

  /// [trackId] preselects a track, e.g. when coming from Explore.
  Future<void> load({String? trackId}) async {
    final tracks = (await _getTracks()).value ?? const <TrackOverview>[];
    if (isClosed) return;
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
      ),
    );
  }

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
    await _addUserRoadmap(current.selectedTrackId!, current.level);
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
