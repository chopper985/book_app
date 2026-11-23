// Package imports:
import 'package:material_ui/material_ui.dart';

// Project imports:
import 'package:interview_practice/core/app/colors/app_palette.dart';
import 'package:interview_practice/core/app/languages/data/localization.dart';
import 'package:interview_practice/core/app/themes/data/app_text.dart';
import 'package:interview_practice/core/injection/injection_container.dart';
import 'package:interview_practice/core/navigator/app_router.dart';
import 'package:interview_practice/features/practice/domain/entities/session_result.dart';
import 'package:interview_practice/features/practice/domain/usecase/find_completed_result.dart';

enum _RetryChoice { retry, viewResult }

/// Opens a practice. When the learner already completed it, asks first:
/// retry, view the last result, or cancel.
Future<void> openPractice(
  BuildContext context, {
  required String setId,
  List<String>? onlyQuestionIds,
}) async {
  final completed = await getIt<FindCompletedResult>()(
    setId,
    onlyQuestionIds: onlyQuestionIds,
  );
  if (!context.mounted) return;

  final route = PracticeRoute(setId: setId, only: onlyQuestionIds?.join(','));
  if (completed == null) {
    await route.push<void>(context);
    return;
  }

  final choice = await showDialog<_RetryChoice>(
    context: context,
    builder: (context) => _CompletedDialog(result: completed),
  );
  if (!context.mounted) return;
  switch (choice) {
    case _RetryChoice.retry:
      await route.push<void>(context);
    case _RetryChoice.viewResult:
      await ResultRoute(sessionId: completed.sessionId).push<void>(context);
    case null:
      break;
  }
}

class _CompletedDialog extends StatelessWidget {
  final SessionResult result;

  const _CompletedDialog({required this.result});

  @override
  Widget build(BuildContext context) {
    final graded = result.gradedCount > 0;
    return AlertDialog(
      backgroundColor: AppPalette.surfaceContainer,
      title: Text(
        Strings.retryTitle.i18n,
        style: AppText.sans(18, height: 26, weight: FontWeight.w600),
      ),
      content: Text(
        graded
            ? Strings.retryMessageScore.i18n.fill([result.scorePercent])
            : Strings.retryMessage.i18n,
        style: AppText.sans(
          14,
          height: 20,
          color: AppPalette.onSurfaceVariant,
        ),
      ),
      actionsOverflowButtonSpacing: 4,
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(
            Strings.retryCancel.i18n,
            style: AppText.sans(
              14,
              weight: FontWeight.w600,
              color: AppPalette.onSurfaceVariant,
            ),
          ),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(_RetryChoice.viewResult),
          child: Text(
            Strings.retryViewResult.i18n,
            style: AppText.sans(14, weight: FontWeight.w600),
          ),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(_RetryChoice.retry),
          child: Text(
            Strings.retryConfirm.i18n,
            style: AppText.sans(
              14,
              weight: FontWeight.w600,
              color: AppPalette.primary,
            ),
          ),
        ),
      ],
    );
  }
}
