// Project imports:
import 'package:AppName/features/catalog/domain/entities/track_overview.dart';

/// Keeps tracks of one category (`null` keeps every category) whose name,
/// tagline or topic names contain [query], ignoring case and Vietnamese
/// diacritics ("lap trinh" finds "Lập trình").
class FilterTracks {
  const FilterTracks();

  List<TrackOverview> call(
    List<TrackOverview> tracks,
    String? category, {
    String query = '',
  }) {
    final needle = normalize(query.trim());
    return [
      for (final overview in tracks)
        if ((category == null || overview.track.category == category) &&
            (needle.isEmpty || _haystack(overview).contains(needle)))
          overview,
    ];
  }

  static String _haystack(TrackOverview overview) {
    final track = overview.track;
    return normalize(
      [
        ...track.name.values.values,
        ...?track.tagline?.values.values,
        for (final topic in track.topics) ...topic.name.values.values,
      ].join(' '),
    );
  }

  static const Map<String, String> _folds = {
    'a': 'àáạảãâầấậẩẫăằắặẳẵ',
    'e': 'èéẹẻẽêềếệểễ',
    'i': 'ìíịỉĩ',
    'o': 'òóọỏõôồốộổỗơờớợởỡ',
    'u': 'ùúụủũưừứựửữ',
    'y': 'ỳýỵỷỹ',
    'd': 'đ',
  };

  static final Map<int, String> _foldByRune = {
    for (final MapEntry(key: plain, value: marked) in _folds.entries)
      for (final rune in marked.runes) rune: plain,
  };

  /// Lower case without Vietnamese diacritics.
  static String normalize(String text) {
    final buffer = StringBuffer();
    for (final rune in text.toLowerCase().runes) {
      buffer.write(_foldByRune[rune] ?? String.fromCharCode(rune));
    }
    return buffer.toString();
  }
}
