// Project imports:
import 'package:interview_practice/core/utils/dio_api/result.dart';
import 'package:interview_practice/features/catalog/domain/entities/explore_dashboard.dart';
import 'package:interview_practice/features/catalog/domain/entities/position_detail.dart';
import 'package:interview_practice/features/catalog/domain/entities/track_detail.dart';
import 'package:interview_practice/features/catalog/domain/entities/track_overview.dart';
import 'package:interview_practice/features/content/domain/entities/position.dart';
import 'package:interview_practice/features/content/domain/entities/question.dart';

abstract class CatalogRepository {
  /// All tracks in display order, available or not.
  Future<Result<List<TrackOverview>>> getTracks();

  /// Learner data for Explore, computed from practice history.
  Future<ExploreDashboard> getDashboard();

  /// Job positions defined by the content.
  Future<Result<List<Position>>> getPositions();

  /// Tracks and progress of a position option up to [level]; fails with
  /// `TrackNotFoundFailure` when the position or option is unknown.
  Future<Result<PositionDetail>> getPositionDetail(
    String positionId,
    String optionId,
    QuestionLevel level,
  );

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
