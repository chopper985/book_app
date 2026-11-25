// Package imports:
import 'package:material_ui/material_ui.dart';

// Project imports:
import 'package:interview_practice/core/app/colors/app_palette.dart';
import 'package:interview_practice/core/app/themes/data/app_text.dart';
import 'package:interview_practice/core/utils/sizer/design_size.dart';
import 'package:interview_practice/features/catalog/domain/entities/track_overview.dart';
import 'package:interview_practice/features/catalog/presentation/widgets/track_icon_box.dart';
import 'package:interview_practice/features/content/presentation/extensions/localized_text_extension.dart';

/// The learner's roadmaps as small horizontal cards (logo, name, progress).
class CompactRoadmapStrip extends StatelessWidget {
  final List<TrackOverview> tracks;

  /// Completed ratio (0..1) per track id.
  final Map<String, double> completion;
  final ValueChanged<TrackOverview> onOpen;

  const CompactRoadmapStrip({
    super.key,
    required this.tracks,
    required this.completion,
    required this.onOpen,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final overview in tracks) ...[
            _CompactCard(
              overview: overview,
              completion: completion[overview.track.id] ?? 0,
              onTap: () => onOpen(overview),
            ),
            SizedBox(width: 8.dsp),
          ],
        ],
      ),
    );
  }
}

class _CompactCard extends StatelessWidget {
  final TrackOverview overview;
  final double completion;
  final VoidCallback onTap;

  const _CompactCard({
    required this.overview,
    required this.completion,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(8.dsp);
    final percent = (completion.clamp(0, 1) * 100).round();
    return SizedBox(
      width: 132.dsp,
      child: Material(
        color: AppPalette.surfaceLow,
        shape: RoundedRectangleBorder(
          borderRadius: radius,
          side: const BorderSide(color: AppPalette.surfaceHigh),
        ),
        child: InkWell(
          borderRadius: radius,
          onTap: onTap,
          child: Padding(
            padding: EdgeInsets.all(10.dsp),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    TrackIconBox(trackId: overview.track.id, size: 28),
                    const Spacer(),
                    Text(
                      '$percent%',
                      style:
                          AppText.mono(11, height: 16, color: AppPalette.teal),
                    ),
                  ],
                ),
                SizedBox(height: 8.dsp),
                Text(
                  overview.track.name.text,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppText.sans(13, height: 18, weight: FontWeight.w600),
                ),
                SizedBox(height: 6.dsp),
                ClipRRect(
                  borderRadius: BorderRadius.circular(999),
                  child: LinearProgressIndicator(
                    value: completion.clamp(0, 1).toDouble(),
                    minHeight: 4.dsp,
                    color: AppPalette.primaryStrong,
                    backgroundColor: AppPalette.surfaceHigh,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
