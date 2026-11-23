// Package imports:
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart';

// Project imports:
import 'package:interview_practice/core/app/colors/app_palette.dart';
import 'package:interview_practice/core/app/languages/data/localization.dart';
import 'package:interview_practice/core/app/themes/data/app_text.dart';
import 'package:interview_practice/core/navigator/app_router.dart';
import 'package:interview_practice/core/utils/sizer/design_size.dart';
import 'package:interview_practice/core/utils/widgets/app_badge.dart';
import 'package:interview_practice/core/utils/widgets/app_progress_bar.dart';
import 'package:interview_practice/features/catalog/domain/entities/position_detail.dart';
import 'package:interview_practice/features/catalog/presentation/cubit/position_detail_cubit.dart';
import 'package:interview_practice/features/catalog/presentation/widgets/position_icon_box.dart';
import 'package:interview_practice/features/catalog/presentation/widgets/track_icon_box.dart';
import 'package:interview_practice/features/catalog/presentation/widgets/track_style.dart';
import 'package:interview_practice/features/content/domain/entities/content_catalog.dart';
import 'package:interview_practice/features/content/domain/entities/question.dart';
import 'package:interview_practice/features/content/presentation/extensions/localized_text_extension.dart';
import 'package:interview_practice/features/content/presentation/extensions/question_level_label.dart';

/// A position roadmap: overall progress, the mixed mock test and each track.
class PositionDetailView extends StatelessWidget {
  final Widget top;

  const PositionDetailView({super.key, required this.top});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PositionDetailCubit, PositionDetailState>(
      builder: (context, state) => switch (state) {
        PositionDetailLoading() => const Center(
            child: CircularProgressIndicator(color: AppPalette.primary),
          ),
        PositionDetailNotFound() => Padding(
            padding: EdgeInsets.all(16.dsp),
            child: Column(
              children: [
                top,
                Expanded(
                  child: Center(
                    child: Text(
                      Strings.trackNotFound.i18n,
                      style: AppText.sans(15, height: 22),
                    ),
                  ),
                ),
              ],
            ),
          ),
        PositionDetailLoaded(:final detail) => _Body(detail: detail, top: top),
      },
    );
  }
}

class _Body extends StatelessWidget {
  final PositionDetail detail;
  final Widget top;

  const _Body({required this.detail, required this.top});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AppProgressBar(
          value: detail.ratio,
          trackColor: Colors.transparent,
          gradient: AppPalette.progressGradient,
        ),
        Expanded(
          child: ListView(
            padding: EdgeInsets.fromLTRB(16.dsp, 12.dsp, 16.dsp, 32.dsp),
            children: [
              top,
              SizedBox(height: 12.dsp),
              _Hero(detail: detail),
              if (detail.mockQuestionIds.isNotEmpty) ...[
                SizedBox(height: 16.dsp),
                _MockCard(detail: detail),
              ],
              SizedBox(height: 24.dsp),
              Text(
                Strings.positionTracks.i18n,
                style: AppText.sans(18, height: 28, weight: FontWeight.w600),
              ),
              SizedBox(height: 12.dsp),
              for (final track in detail.tracks)
                _TrackRow(progress: track, level: detail.level),
            ],
          ),
        ),
      ],
    );
  }
}

class _Hero extends StatelessWidget {
  final PositionDetail detail;

  const _Hero({required this.detail});

  @override
  Widget build(BuildContext context) {
    final levels = [
      for (final level in QuestionLevel.values)
        if (level.index <= detail.level.index) level.label,
    ].join(' / ');
    return Container(
      padding: EdgeInsets.all(16.dsp),
      decoration: BoxDecoration(
        color: AppPalette.surfaceContainer,
        borderRadius: BorderRadius.circular(12.dsp),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              PositionIconBox(positionId: detail.position.id, size: 48),
              SizedBox(width: 12.dsp),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      detail.position.name.text,
                      style: AppText.sans(
                        20,
                        height: 28,
                        weight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      detail.option.name.text,
                      style: AppText.sans(
                        13,
                        height: 18,
                        color: AppPalette.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 12.dsp),
          AppBadge(
            label: Strings.trackAudienceLevel.i18n.fill([levels]),
            background: AppPalette.surfaceLowest,
            foreground: AppPalette.onSurface,
          ),
          SizedBox(height: 16.dsp),
          Row(
            children: [
              Expanded(
                child: Text(
                  Strings.positionProgress.i18n,
                  style: AppText.sans(13, height: 18),
                ),
              ),
              Text(
                '${(detail.ratio * 100).round()}% '
                '(${Strings.positionAnswered.i18n.fill([
                      detail.answered,
                      detail.total,
                    ])})',
                style: AppText.mono(12, height: 16, color: AppPalette.primary),
              ),
            ],
          ),
          SizedBox(height: 8.dsp),
          AppProgressBar(
            value: detail.ratio,
            gradient: AppPalette.progressGradient,
          ),
        ],
      ),
    );
  }
}

class _MockCard extends StatelessWidget {
  final PositionDetail detail;

  const _MockCard({required this.detail});

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(8.dsp);
    final count =
        detail.mockQuestionIds.length < ContentCatalog.positionMockQuestions
            ? detail.mockQuestionIds.length
            : ContentCatalog.positionMockQuestions;
    return Material(
      color: AppPalette.primaryStrong,
      borderRadius: radius,
      child: InkWell(
        borderRadius: radius,
        onTap: () => PracticeRoute(
          setId: detail.mockSetId,
          only: PositionDetailCubit.pickMockQuestions(detail.mockQuestionIds)
              ?.join(','),
        ).push<void>(context),
        child: Padding(
          padding: EdgeInsets.all(16.dsp),
          child: Row(
            children: [
              Icon(
                Icons.timer_outlined,
                size: 28.dsp,
                color: AppPalette.onPrimaryStrong,
              ),
              SizedBox(width: 12.dsp),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      Strings.positionMockTitle.i18n
                          .fill([detail.position.name.text]),
                      style: AppText.sans(
                        16,
                        height: 24,
                        weight: FontWeight.w700,
                        color: AppPalette.onPrimaryStrong,
                      ),
                    ),
                    Text(
                      Strings.positionMockSubtitle.i18n.fill(
                        [count, ContentCatalog.positionMockMinutes],
                      ),
                      style: AppText.sans(
                        12,
                        height: 16,
                        color: AppPalette.onPrimaryStrong,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.play_circle_fill,
                size: 32.dsp,
                color: AppPalette.onPrimaryStrong,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TrackRow extends StatelessWidget {
  final PositionTrackProgress progress;
  final QuestionLevel level;

  const _TrackRow({required this.progress, required this.level});

  @override
  Widget build(BuildContext context) {
    final track = progress.track;
    final style = TrackStyle.of(track.id);
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
          onTap: () => TrackRoadmapRoute(trackId: track.id, level: level.name)
              .push<void>(context),
          child: Padding(
            padding: EdgeInsets.all(12.dsp),
            child: Row(
              children: [
                TrackIconBox(trackId: track.id),
                SizedBox(width: 12.dsp),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              track.name.text,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppText.sans(
                                14,
                                height: 20,
                                weight: FontWeight.w600,
                              ),
                            ),
                          ),
                          SizedBox(width: 6.dsp),
                          AppBadge(
                            label: (progress.isMain
                                    ? Strings.positionMain
                                    : Strings.positionCore)
                                .i18n,
                            background: progress.isMain
                                ? AppPalette.primaryContainer
                                : AppPalette.surfaceHigh,
                            foreground: progress.isMain
                                ? AppPalette.primary
                                : AppPalette.onSurfaceVariant,
                          ),
                        ],
                      ),
                      SizedBox(height: 8.dsp),
                      AppProgressBar(
                        value: progress.ratio,
                        color: style.barColor,
                      ),
                      SizedBox(height: 4.dsp),
                      Text(
                        Strings.positionAnswered.i18n
                            .fill([progress.answered, progress.total]),
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
                Icon(
                  Icons.chevron_right,
                  size: 20.dsp,
                  color: AppPalette.onSurfaceVariant,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
