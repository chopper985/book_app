// Project imports:
import 'package:AppName/core/utils/dio_api/result.dart';
import 'package:AppName/features/catalog/domain/entities/explore_dashboard.dart';
import 'package:AppName/features/catalog/domain/entities/track_detail.dart';
import 'package:AppName/features/catalog/domain/entities/track_overview.dart';
import 'package:AppName/features/content/domain/entities/question.dart';

abstract class CatalogRepository {
  /// All tracks in display order, available or not.
  Future<Result<List<TrackOverview>>> getTracks();

  /// Learner data for Explore, computed from practice history.
  Future<ExploreDashboard> getDashboard();

  /// Fires when practice history changes, so learner data should be reloaded.
  Stream<void> get progressChanges;

  /// Fails with `TrackNotFoundFailure` when the track is missing or not
  /// available. [maxLevel] keeps questions up to that level, and only the
  /// sets whose questions all fit.
  Future<Result<TrackDetail>> getTrackDetail(
    String trackId, {
    QuestionLevel? maxLevel,
  });
}
