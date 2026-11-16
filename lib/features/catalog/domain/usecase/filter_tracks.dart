// Project imports:
import 'package:AppName/features/catalog/domain/entities/track_overview.dart';

/// Keeps tracks of one Explore category; `null` keeps every track.
class FilterTracks {
  const FilterTracks();

  List<TrackOverview> call(List<TrackOverview> tracks, String? category) =>
      category == null
          ? tracks
          : tracks.where((t) => t.track.category == category).toList();
}
