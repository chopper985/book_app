// Package imports:
import 'package:equatable/equatable.dart';

enum ContentIssueCode {
  missingFile,
  invalidFormat,
  duplicateId,
  missingReference,
  trackMismatch,
  invalidAnswer,
  missingOptions,
  missingKeyPoints,
  missingExplanation,
  missingTranslation,
  emptySet,
  invalidVersion,
}

/// A problem found while reading or validating bundled content.
class ContentIssue extends Equatable {
  final ContentIssueCode code;

  /// Where the problem is, e.g. `dart/questions.json › dart.null_safety.001`.
  final String path;

  /// Extra technical detail such as the missing id or the parse error.
  final String detail;

  const ContentIssue({
    required this.code,
    required this.path,
    this.detail = '',
  });

  @override
  String toString() =>
      '[${code.name}] $path${detail.isEmpty ? '' : ': $detail'}';

  @override
  List<Object?> get props => [code, path, detail];
}
