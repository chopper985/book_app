// Project imports:
import 'package:AppName/core/utils/dio_api/result.dart';
import 'package:AppName/features/catalog/domain/entities/explore_dashboard.dart';
import 'package:AppName/features/catalog/domain/entities/track_detail.dart';
import 'package:AppName/features/catalog/domain/entities/track_overview.dart';

abstract class CatalogRepository {
  /// All tracks in display order, available or not.
  Future<Result<List<TrackOverview>>> getTracks();

  /// Learner data for Explore (mocked for now).
  Future<ExploreDashboard> getDashboard();

  /// Fails with `TrackNotFoundFailure` when the track is missing or not
  /// available.
  Future<Result<TrackDetail>> getTrackDetail(String trackId);
}
