// Dart imports:
import 'dart:async';

// Package imports:
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

// Project imports:
import 'package:interview_practice/core/analytics/app_analytics.dart';
import 'package:interview_practice/features/catalog/domain/entities/explore_dashboard.dart';
import 'package:interview_practice/features/catalog/domain/entities/track_overview.dart';
import 'package:interview_practice/features/catalog/domain/usecase/get_explore_data.dart';
import 'package:interview_practice/features/practice/domain/usecase/practice_usecases.dart';
import 'package:interview_practice/features/profile/domain/entities/learner_profile.dart';
import 'package:interview_practice/features/profile/domain/usecase/profile_usecases.dart';

part 'profile_state.dart';

@injectable
class ProfileCubit extends Cubit<ProfileState> {
  final GetProfile _getProfile;
  final GetAvatarPath _getAvatarPath;
  final GetExploreDashboard _getDashboard;
  final GetTracks _getTracks;
  final ClearPracticeHistory _clearPracticeHistory;
  final AppAnalytics _analytics;
  late final StreamSubscription<void> _subscription;

  ProfileCubit(
    this._getProfile,
    this._getAvatarPath,
    this._getDashboard,
    this._getTracks,
    this._clearPracticeHistory,
    WatchProgress watchProgress, {
    AppAnalytics analytics = const NoopAppAnalytics(),
  })  : _analytics = analytics,
        super(const ProfileLoading()) {
    _subscription = watchProgress().listen((_) => load());
  }

  /// Loads once with a spinner, then refreshes in place.
  Future<void> load() async {
    final tracks = (await _getTracks()).value ?? const <TrackOverview>[];
    final dashboard = await _getDashboard();
    final byId = {for (final overview in tracks) overview.track.id: overview};
    final profile = _getProfile();
    final avatarPath = await _getAvatarPath(profile?.avatarFileName);
    if (isClosed) return;
    emit(
      ProfileLoaded(
        profile: profile,
        avatarPath: avatarPath,
        learner: dashboard.learner,
        stack: [
          for (final id in profile?.techStack ?? const <String>[])
            if (byId[id] case final overview?) overview,
        ],
      ),
    );
  }

  /// Deletes practice history; the change stream reloads the state.
  Future<void> resetProgress() async {
    await _clearPracticeHistory();
    _analytics.progressReset();
  }

  /// Records the switch; the screen applies the locale itself.
  void languageChanged(String languageCode) {
    _analytics
      ..languageChanged(languageCode)
      ..setUserProperty('language', languageCode);
  }

  @override
  Future<void> close() async {
    await _subscription.cancel();
    return super.close();
  }
}
