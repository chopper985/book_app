// Flutter imports:
import 'package:material_ui/material_ui.dart';

// Package imports:
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

// Project imports:
import 'package:interview_practice/core/app/colors/app_palette.dart';
import 'package:interview_practice/core/app/languages/data/localization.dart';
import 'package:interview_practice/core/app/themes/data/app_text.dart';
import 'package:interview_practice/core/navigator/app_router.dart';
import 'package:interview_practice/core/utils/sizer/design_size.dart';
import 'package:interview_practice/core/utils/widgets/app_badge.dart';
import 'package:interview_practice/features/content/domain/entities/question.dart';
import 'package:interview_practice/features/content/presentation/extensions/localized_text_extension.dart';
import 'package:interview_practice/features/content/presentation/extensions/question_level_label.dart';
import 'package:interview_practice/features/practice/domain/entities/practice_bundle.dart';
import 'package:interview_practice/features/practice/domain/repositories/practice_gate.dart';
import 'package:interview_practice/features/practice/presentation/cubit/practice_cubit.dart';
import 'package:interview_practice/features/practice/presentation/widgets/code_block.dart';
import 'package:interview_practice/features/practice/presentation/widgets/practice_header.dart';
import 'package:interview_practice/features/practice/presentation/widgets/practice_note_box.dart';
import 'package:interview_practice/features/practice/presentation/widgets/practice_option_tile.dart';
import 'package:interview_practice/features/practice/presentation/widgets/practice_step_tracker.dart';
import 'package:interview_practice/features/premium/presentation/cubit/quota_cubit.dart';

/// "Làm bài - Câu hỏi phỏng vấn": one question at a time.
class PracticeScreen extends StatefulWidget {
  const PracticeScreen({super.key});

  @override
  State<PracticeScreen> createState() => _PracticeScreenState();
}

class _PracticeScreenState extends State<PracticeScreen> {
  final ScrollController _scroll = ScrollController();

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  void _onStateChanged(BuildContext context, PracticeState state) {
    if (state is PracticeSubmitted) {
      ResultRoute(sessionId: state.sessionId).pushReplacement(context);
    } else if (state is PracticeInProgress && _scroll.hasClients) {
      _scroll.jumpTo(0);
    }
  }

  Future<void> _confirmLeave(BuildContext context) async {
    final leave = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppPalette.surfaceContainer,
        title: Text(
          Strings.practiceLeaveTitle.i18n,
          style: AppText.sans(18, height: 26, weight: FontWeight.w600),
        ),
        content: Text(
          Strings.practiceLeaveMessage.i18n,
          style: AppText.sans(
            14,
            height: 20,
            color: AppPalette.onSurfaceVariant,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(
              Strings.practiceLeaveCancel.i18n,
              style: AppText.sans(14, weight: FontWeight.w600),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(
              Strings.practiceLeaveConfirm.i18n,
              style: AppText.sans(
                14,
                weight: FontWeight.w600,
                color: AppPalette.error,
              ),
            ),
          ),
        ],
      ),
    );
    if ((leave ?? false) && context.mounted) context.pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppPalette.surface,
      body: BlocConsumer<PracticeCubit, PracticeState>(
        listenWhen: (previous, current) =>
            current is PracticeSubmitted ||
            (previous is PracticeInProgress &&
                current is PracticeInProgress &&
                previous.bundle.session.currentIndex !=
                    current.bundle.session.currentIndex),
        listener: _onStateChanged,
        builder: (context, state) => switch (state) {
          PracticeInProgress(:final bundle) => PopScope(
              canPop: false,
              onPopInvokedWithResult: (didPop, _) {
                if (!didPop) _confirmLeave(context);
              },
              child: _InProgress(
                bundle: bundle,
                scroll: _scroll,
                onBack: () => _confirmLeave(context),
              ),
            ),
          PracticeNotFound() => const _NotFound(),
          PracticeLocked(:final reason) => _Locked(reason: reason),
          PracticeLoading() || PracticeSubmitted() => const Center(
              child: CircularProgressIndicator(color: AppPalette.primary),
            ),
        },
      ),
    );
  }
}

class _InProgress extends StatelessWidget {
  final PracticeBundle bundle;
  final ScrollController scroll;
  final VoidCallback onBack;

  const _InProgress({
    required this.bundle,
    required this.scroll,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<PracticeCubit>();
    final session = bundle.session;
    final question = bundle.currentQuestion;
    final selectedId = session.answers[question.id];
    final topic = bundle.track.topicById(question.topicId);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        PracticeHeader(pillLabel: bundle.track.name.text, onBack: onBack),
        PracticeStepTracker(
          session: session,
          typeLabel: _typeLabel(question.type),
          onToggleFlag: cubit.toggleFlag,
          onTimeout: () => cubit.submit(timedOut: true),
        ),
        Expanded(
          child: SingleChildScrollView(
            controller: scroll,
            padding: EdgeInsets.fromLTRB(16.dsp, 0, 16.dsp, 24.dsp),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Wrap(
                  spacing: 8.dsp,
                  runSpacing: 8.dsp,
                  children: [
                    AppBadge(
                      label: topic?.name.text ?? bundle.track.name.text,
                      uppercase: true,
                      background: AppPalette.primaryContainer,
                      foreground: AppPalette.primary,
                    ),
                    AppBadge(
                      label: Strings.practiceDifficulty.i18n
                          .fill([_levelLabel(question.level)]),
                      background: AppPalette.surfaceHigh,
                      foreground: AppPalette.onSurfaceVariant,
                    ),
                  ],
                ),
                SizedBox(height: 12.dsp),
                Text(
                  question.prompt.text,
                  style: AppText.sans(18, height: 26, weight: FontWeight.w600),
                ),
                if (question.code case final code?) ...[
                  SizedBox(height: 16.dsp),
                  CodeBlock(snippet: code, fileStem: question.topicId),
                ],
                SizedBox(height: 24.dsp),
                if (question.type.isAutoGraded)
                  for (final (index, option) in question.options.indexed) ...[
                    if (index > 0) SizedBox(height: 12.dsp),
                    PracticeOptionTile(
                      letter: String.fromCharCode(65 + index),
                      text: option.text.text,
                      selected: option.id == selectedId,
                      onTap: () => cubit.selectOption(option.id),
                    ),
                  ]
                else
                  PracticeNoteBox(
                    icon: Icons.record_voice_over_outlined,
                    iconColor: AppPalette.purple,
                    background: AppPalette.purpleContainer,
                    text: Strings.practiceSelfExplainHint.i18n,
                  ),
                SizedBox(height: 24.dsp),
                PracticeNoteBox(
                  icon: Icons.lightbulb_outline,
                  label: Strings.practiceTipLabel.i18n,
                  text: _tip(question.type),
                ),
              ],
            ),
          ),
        ),
        _Footer(
          isLast: session.isLastQuestion,
          onPressed: session.isLastQuestion ? cubit.submit : cubit.next,
        ),
      ],
    );
  }

  static String _typeLabel(QuestionType type) => switch (type) {
        QuestionType.multipleChoice => Strings.practiceTypeMultipleChoice.i18n,
        QuestionType.outputPrediction =>
          Strings.practiceTypeOutputPrediction.i18n,
        QuestionType.findBug => Strings.practiceTypeFindBug.i18n,
        QuestionType.selfExplain => Strings.practiceTypeSelfExplain.i18n,
      };

  static String _tip(QuestionType type) => switch (type) {
        QuestionType.multipleChoice => Strings.practiceTipMultipleChoice.i18n,
        QuestionType.outputPrediction =>
          Strings.practiceTipOutputPrediction.i18n,
        QuestionType.findBug => Strings.practiceTipFindBug.i18n,
        QuestionType.selfExplain => Strings.practiceTipSelfExplain.i18n,
      };

  static String _levelLabel(QuestionLevel level) => level.label;
}

class _Footer extends StatelessWidget {
  final bool isLast;
  final VoidCallback onPressed;

  const _Footer({required this.isLast, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(8.dsp);
    return Container(
      decoration: const BoxDecoration(
        color: AppPalette.surface,
        border: Border(top: BorderSide(color: AppPalette.surfaceLow)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.all(16.dsp),
          child: DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: radius,
              boxShadow: [
                BoxShadow(
                  color: AppPalette.primaryStrong.withValues(alpha: 0.3),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Material(
              color: AppPalette.primaryStrong,
              borderRadius: radius,
              child: InkWell(
                onTap: onPressed,
                borderRadius: radius,
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: 56.dsp),
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 16.dsp,
                      vertical: 8.dsp,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Flexible(
                          child: Text(
                            isLast
                                ? Strings.practiceSubmit.i18n
                                : Strings.practiceNext.i18n,
                            textAlign: TextAlign.center,
                            style: AppText.sans(
                              16,
                              height: 24,
                              weight: FontWeight.w600,
                              color: AppPalette.onPrimaryStrong,
                            ),
                          ),
                        ),
                        SizedBox(width: 8.dsp),
                        Icon(
                          isLast ? Icons.check : Icons.arrow_forward,
                          size: 18.dsp,
                          color: AppPalette.onPrimaryStrong,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NotFound extends StatelessWidget {
  const _NotFound();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Center(
        child: Padding(
          padding: EdgeInsets.all(24.dsp),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                Strings.practiceNotFound.i18n,
                textAlign: TextAlign.center,
                style: AppText.sans(16, height: 24, weight: FontWeight.w600),
              ),
              SizedBox(height: 16.dsp),
              TextButton(
                onPressed: () => context.pop(),
                child: Text(
                  Strings.practiceBack.i18n,
                  style: AppText.sans(
                    14,
                    weight: FontWeight.w600,
                    color: AppPalette.primary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// The plan does not allow this session: explains why and opens the plans.
class _Locked extends StatelessWidget {
  final PracticeDenial reason;

  const _Locked({required this.reason});

  @override
  Widget build(BuildContext context) {
    final premiumLevel = reason == PracticeDenial.premiumLevel;
    final quota = context.watch<QuotaCubit>().state;
    return SafeArea(
      child: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(24.dsp),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                premiumLevel
                    ? Icons.workspace_premium_rounded
                    : Icons.hourglass_bottom_rounded,
                size: 48.dsp,
                color:
                    premiumLevel ? AppPalette.purpleDeep : AppPalette.primary,
              ),
              SizedBox(height: 16.dsp),
              Text(
                premiumLevel
                    ? Strings.lockedPremiumTitle.i18n
                    : Strings.lockedQuotaTitle.i18n,
                textAlign: TextAlign.center,
                style: AppText.sans(20, height: 28, weight: FontWeight.w700),
              ),
              SizedBox(height: 8.dsp),
              Text(
                premiumLevel
                    ? Strings.lockedPremiumMessage.i18n
                    : Strings.lockedQuotaMessage.i18n.fill([quota.dailyLimit]),
                textAlign: TextAlign.center,
                style: AppText.sans(
                  14,
                  height: 20,
                  color: AppPalette.onSurfaceVariant,
                ),
              ),
              SizedBox(height: 24.dsp),
              FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: AppPalette.primaryStrong,
                  foregroundColor: AppPalette.onPrimaryStrong,
                  minimumSize: Size(200.dsp, 48.dsp),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.dsp),
                  ),
                ),
                onPressed: () => const PaywallRoute().pushReplacement(context),
                child: Text(
                  Strings.lockedSeePlans.i18n,
                  style: AppText.sans(
                    15,
                    weight: FontWeight.w600,
                    color: AppPalette.onPrimaryStrong,
                  ),
                ),
              ),
              SizedBox(height: 8.dsp),
              TextButton(
                onPressed: () => context.pop(),
                child: Text(
                  Strings.practiceBack.i18n,
                  style: AppText.sans(
                    14,
                    weight: FontWeight.w600,
                    color: AppPalette.onSurfaceVariant,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
