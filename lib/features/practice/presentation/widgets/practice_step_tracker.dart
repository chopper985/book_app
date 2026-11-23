// Package imports:
import 'package:material_ui/material_ui.dart';

// Project imports:
import 'package:interview_practice/core/app/colors/app_palette.dart';
import 'package:interview_practice/core/app/languages/data/localization.dart';
import 'package:interview_practice/core/app/themes/data/app_text.dart';
import 'package:interview_practice/core/utils/sizer/design_size.dart';
import 'package:interview_practice/core/utils/widgets/app_svg.dart';
import 'package:interview_practice/features/practice/domain/entities/practice_session.dart';
import 'package:interview_practice/features/practice/presentation/widgets/practice_timer_pill.dart';
import 'package:interview_practice/gen/assets.gen.dart';

/// Step counter, question type, timer, flag and stepped progress bar.
class PracticeStepTracker extends StatelessWidget {
  final PracticeSession session;
  final String typeLabel;
  final VoidCallback onToggleFlag;
  final VoidCallback onTimeout;

  const PracticeStepTracker({
    super.key,
    required this.session,
    required this.typeLabel,
    required this.onToggleFlag,
    required this.onTimeout,
  });

  @override
  Widget build(BuildContext context) {
    final total = session.questionIds.length;
    final flagged = session.flagged.contains(session.currentQuestionId);

    return Padding(
      padding: EdgeInsets.fromLTRB(16.dsp, 8.dsp, 16.dsp, 16.dsp),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Text(
                Strings.practiceQuestionCounter.i18n
                    .fill([session.currentIndex + 1, total]),
                style: AppText.mono(
                  12,
                  height: 16,
                  weight: FontWeight.w700,
                  color: AppPalette.primary,
                  letterSpacing: 0.6,
                ),
              ),
              SizedBox(width: 8.dsp),
              Container(
                width: 6.dsp,
                height: 6.dsp,
                decoration: BoxDecoration(
                  color: AppPalette.surfaceHighest,
                  borderRadius: BorderRadius.circular(12.dsp),
                ),
              ),
              SizedBox(width: 8.dsp),
              Expanded(
                child: Text(
                  typeLabel,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppText.sans(
                    12,
                    height: 18,
                    color: AppPalette.onSurfaceVariant,
                  ),
                ),
              ),
              SizedBox(width: 8.dsp),
              PracticeTimerPill(
                key: ValueKey(session.id),
                startedAt: session.startedAt,
                endsAt: session.endsAt,
                onTimeout: onTimeout,
              ),
              SizedBox(width: 8.dsp),
              Tooltip(
                message: Strings.practiceFlag.i18n,
                child: Material(
                  color: flagged
                      ? AppPalette.primaryContainer
                      : AppPalette.surfaceContainer,
                  borderRadius: BorderRadius.circular(12.dsp),
                  child: InkWell(
                    onTap: onToggleFlag,
                    borderRadius: BorderRadius.circular(12.dsp),
                    child: SizedBox(
                      width: 32.dsp,
                      height: 32.dsp,
                      child: Center(
                        child: AppSvg(
                          Assets.figma.practice.icFlag,
                          width: 9.333,
                          height: 12,
                          color: flagged
                              ? AppPalette.primary
                              : AppPalette.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 8.dsp),
          Row(
            children: [
              for (var i = 0; i < total; i++) ...[
                if (i > 0) SizedBox(width: 6.dsp),
                Expanded(child: _Segment(state: _segmentOf(i))),
              ],
            ],
          ),
        ],
      ),
    );
  }

  _SegmentState _segmentOf(int index) {
    if (index == session.currentIndex) return _SegmentState.current;
    final answered = session.answers.containsKey(session.questionIds[index]);
    return answered ? _SegmentState.answered : _SegmentState.pending;
  }
}

enum _SegmentState { answered, current, pending }

class _Segment extends StatelessWidget {
  final _SegmentState state;

  const _Segment({required this.state});

  @override
  Widget build(BuildContext context) {
    final color = switch (state) {
      _SegmentState.answered => AppPalette.teal,
      // Figma: primaryStrong under a 20% white overlay.
      _SegmentState.current => Color.alphaBlend(
          Colors.white.withValues(alpha: 0.2),
          AppPalette.primaryStrong,
        ),
      _SegmentState.pending => AppPalette.surfaceHigh,
    };
    return Container(
      height: 6.dsp,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12.dsp),
      ),
    );
  }
}
