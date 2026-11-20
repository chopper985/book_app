// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:AppName/core/app/colors/app_palette.dart';
import 'package:AppName/core/app/languages/data/localization.dart';
import 'package:AppName/core/app/themes/data/app_text.dart';
import 'package:AppName/core/utils/sizer/design_size.dart';
import 'package:AppName/features/catalog/presentation/widgets/track_icon_box.dart';
import 'package:AppName/features/content/presentation/extensions/localized_text_extension.dart';
import 'package:AppName/features/practice/domain/entities/practice_hub.dart';

class HubSectionTitle extends StatelessWidget {
  final String title;

  const HubSectionTitle(this.title, {super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12.dsp),
      child: Text(
        title,
        style: AppText.sans(18, height: 28, weight: FontWeight.w600),
      ),
    );
  }
}

/// Sessions, average score and questions to review.
class HubStats extends StatelessWidget {
  final PracticeHub hub;

  const HubStats({super.key, required this.hub});

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: _StatTile(
              label: Strings.hubStatSessions.i18n,
              value: '${hub.sessionCount}',
              color: AppPalette.primary,
            ),
          ),
          SizedBox(width: 8.dsp),
          Expanded(
            child: _StatTile(
              label: Strings.hubStatAverage.i18n,
              value: '${hub.averageScorePercent}%',
              color: AppPalette.teal,
            ),
          ),
          SizedBox(width: 8.dsp),
          Expanded(
            child: _StatTile(
              label: Strings.hubStatMistakes.i18n,
              value: '${hub.mistakeCount}',
              color: hub.mistakeCount == 0
                  ? AppPalette.onSurfaceVariant
                  : AppPalette.error,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _StatTile({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(12.dsp),
      decoration: BoxDecoration(
        color: AppPalette.surfaceContainer,
        borderRadius: BorderRadius.circular(8.dsp),
        border: Border.all(color: AppPalette.surfaceHigh),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: AppText.mono(10, height: 14)),
          SizedBox(height: 4.dsp),
          Text(
            value,
            style: AppText.mono(
              20,
              height: 28,
              weight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

/// Card shell shared by the hub rows: track icon, two lines and a trailing
/// widget.
class HubRow extends StatelessWidget {
  final String trackId;
  final String title;
  final String subtitle;
  final Widget trailing;
  final VoidCallback onTap;

  const HubRow({
    super.key,
    required this.trackId,
    required this.title,
    required this.subtitle,
    required this.trailing,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(8.dsp);
    return Padding(
      padding: EdgeInsets.only(bottom: 8.dsp),
      child: Material(
        color: AppPalette.surfaceContainer,
        shape: RoundedRectangleBorder(
          borderRadius: radius,
          side: const BorderSide(color: AppPalette.surfaceHigh),
        ),
        child: InkWell(
          borderRadius: radius,
          onTap: onTap,
          child: Padding(
            padding: EdgeInsets.all(12.dsp),
            child: Row(
              children: [
                TrackIconBox(trackId: trackId),
                SizedBox(width: 12.dsp),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: AppText.sans(
                          14,
                          height: 20,
                          weight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 2.dsp),
                      Text(
                        subtitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppText.mono(
                          11,
                          height: 16,
                          weight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 8.dsp),
                trailing,
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class MistakeRow extends StatelessWidget {
  final MistakeGroup group;
  final VoidCallback onTap;

  const MistakeRow({super.key, required this.group, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return HubRow(
      trackId: group.track.id,
      title: group.set.title.text,
      subtitle: Strings.hubMistakeCount.i18n.fill([group.questionIds.length]),
      onTap: onTap,
      trailing: Container(
        padding: EdgeInsets.symmetric(horizontal: 10.dsp, vertical: 6.dsp),
        decoration: BoxDecoration(
          color: AppPalette.errorContainer,
          borderRadius: BorderRadius.circular(6.dsp),
        ),
        child: Text(
          Strings.hubReviewNow.i18n,
          style: AppText.mono(11, height: 16, color: AppPalette.error),
        ),
      ),
    );
  }
}

class QuickPracticeRow extends StatelessWidget {
  final QuickPractice practice;
  final VoidCallback onTap;

  const QuickPracticeRow({
    super.key,
    required this.practice,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return HubRow(
      trackId: practice.track.id,
      title: practice.track.name.text,
      subtitle: Strings.hubQuickSubtitle.i18n.fill([practice.questionCount]),
      onTap: onTap,
      trailing: Icon(
        Icons.play_circle_fill,
        size: 28.dsp,
        color: AppPalette.primaryStrong,
      ),
    );
  }
}

class HistoryRow extends StatelessWidget {
  final HistoryEntry entry;
  final VoidCallback onTap;

  const HistoryRow({super.key, required this.entry, required this.onTap});

  static Color scoreColor(int percent) => percent >= 80
      ? AppPalette.teal
      : percent >= 50
          ? AppPalette.primary
          : AppPalette.error;

  @override
  Widget build(BuildContext context) {
    final result = entry.result;
    final localizations = MaterialLocalizations.of(context);
    final date = result.submittedAt;
    final when = '${localizations.formatShortMonthDay(date)} · '
        '${localizations.formatTimeOfDay(TimeOfDay.fromDateTime(date))}';
    final graded = result.gradedCount > 0;

    return HubRow(
      trackId: entry.track.id,
      title: entry.set.title.text,
      subtitle: result.timedOut
          ? '$when · ${Strings.hubHistoryTimedOut.i18n}'
          : '${entry.track.name.text} · $when',
      onTap: onTap,
      trailing: Text(
        graded ? '${result.scorePercent}%' : '—',
        style: AppText.mono(
          16,
          height: 24,
          weight: FontWeight.w700,
          color: graded
              ? scoreColor(result.scorePercent)
              : AppPalette.onSurfaceVariant,
        ),
      ),
    );
  }
}

/// Muted message for an empty section.
class HubEmpty extends StatelessWidget {
  final String message;

  const HubEmpty(this.message, {super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.dsp),
      decoration: BoxDecoration(
        color: AppPalette.surfaceLow,
        borderRadius: BorderRadius.circular(8.dsp),
        border: Border.all(color: AppPalette.surfaceHigh),
      ),
      child: Text(
        message,
        style: AppText.sans(
          13,
          height: 20,
          color: AppPalette.onSurfaceVariant,
        ),
      ),
    );
  }
}
