// Flutter imports:
import 'package:material_ui/material_ui.dart';

// Package imports:
import 'package:sizer/sizer.dart';

// Project imports:
import 'package:interview_practice/core/app/languages/data/localization.dart';
import 'package:interview_practice/features/content/domain/entities/content_issue.dart';

/// Lists every content problem so the author can fix the data.
class ContentIssueView extends StatelessWidget {
  final List<ContentIssue> issues;
  final VoidCallback? onRetry;

  const ContentIssueView({super.key, required this.issues, this.onRetry});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return ListView.separated(
      padding: EdgeInsets.all(16.3.sp),
      itemCount: issues.length + 1,
      separatorBuilder: (_, __) => SizedBox(height: 11.6.sp),
      itemBuilder: (context, index) {
        if (index == 0) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                Strings.contentInvalidTitle.i18n,
                style: TextStyle(
                  fontSize: 18.3.sp,
                  fontWeight: FontWeight.w700,
                  color: colorScheme.error,
                ),
              ),
              SizedBox(height: 8.2.sp),
              Text(
                Strings.contentInvalidMessage.i18n.fill([issues.length]),
                style: TextStyle(fontSize: 15.3.sp),
              ),
              if (onRetry != null) ...[
                SizedBox(height: 11.6.sp),
                OutlinedButton(
                  onPressed: onRetry,
                  child: Text(Strings.retry.i18n),
                ),
              ],
            ],
          );
        }
        final issue = issues[index - 1];
        return Container(
          padding: EdgeInsets.all(14.2.sp),
          decoration: BoxDecoration(
            color: colorScheme.errorContainer,
            borderRadius: BorderRadius.circular(14.2.sp),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _message(issue),
                style: TextStyle(
                  fontSize: 15.3.sp,
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onErrorContainer,
                ),
              ),
              SizedBox(height: 5.8.sp),
              SelectableText(
                issue.path,
                style: TextStyle(
                  fontSize: 14.2.sp,
                  fontFamily: 'monospace',
                  color: colorScheme.onErrorContainer,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  String _message(ContentIssue issue) {
    final key = switch (issue.code) {
      ContentIssueCode.missingFile => Strings.issueMissingFile,
      ContentIssueCode.invalidFormat => Strings.issueInvalidFormat,
      ContentIssueCode.duplicateId => Strings.issueDuplicateId,
      ContentIssueCode.missingReference => Strings.issueMissingReference,
      ContentIssueCode.trackMismatch => Strings.issueTrackMismatch,
      ContentIssueCode.invalidAnswer => Strings.issueInvalidAnswer,
      ContentIssueCode.missingOptions => Strings.issueMissingOptions,
      ContentIssueCode.missingKeyPoints => Strings.issueMissingKeyPoints,
      ContentIssueCode.missingExplanation => Strings.issueMissingExplanation,
      ContentIssueCode.missingTranslation => Strings.issueMissingTranslation,
      ContentIssueCode.emptySet => Strings.issueEmptySet,
      ContentIssueCode.invalidVersion => Strings.issueInvalidVersion,
      ContentIssueCode.premiumLevelInFreeSet =>
        Strings.issuePremiumLevelInFreeSet,
    };
    final text = key.i18n;
    return text.contains('%s') ? text.fill([issue.detail]) : text;
  }
}
