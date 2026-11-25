// Dart imports:
import 'dart:async';

// Package imports:
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

// Project imports:
import 'package:interview_practice/features/catalog/domain/entities/explore_dashboard.dart';
import 'package:interview_practice/features/catalog/domain/entities/role_technologies.dart';
import 'package:interview_practice/features/catalog/domain/entities/track_detail.dart';
import 'package:interview_practice/features/catalog/domain/entities/track_overview.dart';
import 'package:interview_practice/features/catalog/domain/usecase/get_explore_data.dart';
import 'package:interview_practice/features/catalog/domain/usecase/get_role_technologies.dart';
import 'package:interview_practice/features/catalog/domain/usecase/get_track_detail.dart';
import 'package:interview_practice/features/catalog/domain/usecase/user_roadmaps.dart';
import 'package:interview_practice/features/content/domain/entities/content_failure.dart';
import 'package:interview_practice/features/content/domain/entities/content_issue.dart';
import 'package:interview_practice/features/profile/domain/entities/learner_profile.dart';
import 'package:interview_practice/features/profile/domain/usecase/profile_usecases.dart';

part 'explore_state.dart';

@injectable
class ExploreCubit extends Cubit<ExploreState> {
  final GetTracks _getTracks;
  final GetExploreDashboard _getDashboard;
  final GetProfile _getProfile;
  final OpenTrackRoadmap _openTrackRoadmap;
  final GetRoleTechnologies _getRoleTechnologies;
  final GetUserRoadmaps _getUserRoadmaps;
  final GetTrackDetail _getTrackDetail;
  late final StreamSubscription<void> _progressSubscription;

  ExploreCubit(
    this._getTracks,
    this._getDashboard,
    this._getProfile,
    this._openTrackRoadmap,
    this._getRoleTechnologies,
    this._getUserRoadmaps,
    this._getTrackDetail,
    WatchProgress watchProgress,
  ) : super(const ExploreLoading()) {
    _progressSubscription = watchProgress().listen((_) => refresh());
  }

  Future<void> load() async {
    emit(const ExploreLoading());
    await _emitLoaded();
  }

  /// Reloads without showing the loading state again.
  Future<void> refresh() async {
    if (state is ExploreLoaded) await _emitLoaded();
  }

  Future<void> _emitLoaded() async {
    final result = await _getTracks();
    final tracks = result.value;
    if (tracks == null) {
      final error = result.error;
      if (!isClosed) {
        emit(
          ExploreInvalidContent(
            error is ContentFailure ? error.issues : const [],
          ),
        );
      }
      return;
    }
    final dashboard = await _getDashboard();
    final roles = await _getRoleTechnologies();
    if (isClosed) return;
    final previous = state;
    emit(
      ExploreLoaded(
        tracks: tracks,
        myTracks: _myTracks(tracks, roles),
        dashboard: dashboard,
        roles: roles,
        roadmapTrackIds: _roadmapTrackIds(roles).toSet(),
        selectedRoleId: previous is ExploreLoaded
            ? previous.selectedRoleId
            : _defaultRoleId(roles),
      ),
    );
  }

  void selectRole(String positionId) {
    final current = state;
    if (current is ExploreLoaded) {
      emit(current.copyWith(selectedRoleId: positionId));
    }
  }

  /// The learner's target role from the profile, else the first position.
  String? _defaultRoleId(List<RoleTechnologies> roles) {
    final wanted = switch (_getProfile()?.role) {
      TargetRole.mobile => 'mobile',
      TargetRole.frontend => 'frontend',
      TargetRole.backend || TargetRole.fullstack => 'backend',
      null => null,
    };
    for (final role in roles) {
      if (role.position.id == wanted) return wanted;
    }
    return roles.isEmpty ? null : roles.first.position.id;
  }

  /// Tracks covered by the learner's roadmaps, most recently selected
  /// first. A position roadmap covers every track of its option and the
  /// position's core tracks (e.g. Mobile · Flutter: Flutter, Dart, HTTP, Git).
  List<String> _roadmapTrackIds(List<RoleTechnologies> roles) {
    final ids = <String>{};
    for (final roadmap in _getUserRoadmaps().roadmaps) {
      final position = roadmap.isPosition
          ? roles
              .map((role) => role.position)
              .where((p) => p.id == roadmap.positionId)
              .firstOrNull
          : null;
      final option = position?.optionById(roadmap.optionId ?? '');
      if (position != null && option != null) {
        ids.addAll(position.trackIdsFor(option));
      } else {
        ids.add(roadmap.trackId);
      }
    }
    return ids.toList();
  }

  /// Adds [trackId] to the roadmaps (at the suggested level) and makes it
  /// the active one; nothing changes when it is already there.
  Future<void> addTrack(String trackId) async {
    await _openTrackRoadmap(trackId);
    await refresh();
  }

  /// A short free practice of [trackId] to try it, from the topics of
  /// [positionId] when given; `null` when there is none.
  Future<PracticeTarget?> trialFor(
    String trackId, {
    String? positionId,
  }) async {
    final detail = await _getTrackDetail(trackId, positionId: positionId);
    return detail.value?.quickPractice();
  }

  /// The learner's roadmap tracks; before any roadmap exists, the tech
  /// stack of the profile as suggestions.
  List<TrackOverview> _myTracks(
    List<TrackOverview> tracks,
    List<RoleTechnologies> roles,
  ) {
    final byId = {for (final overview in tracks) overview.track.id: overview};
    final roadmapIds = _roadmapTrackIds(roles);
    final mine = [
      for (final id
          in roadmapIds.isNotEmpty
              ? roadmapIds
              : _getProfile()?.techStack ?? const <String>[])
        if (byId[id] case final overview?) overview,
    ];
    return mine.isNotEmpty
        ? mine
        : tracks.where((overview) => overview.track.isAvailable).toList();
  }

  /// Makes [trackId] the active roadmap (adding it at the suggested level when
  /// the learner has none for it) before switching to the Roadmaps tab.
  Future<void> openTrack(String trackId) => _openTrackRoadmap(trackId);

  @override
  Future<void> close() async {
    await _progressSubscription.cancel();
    return super.close();
  }
}
