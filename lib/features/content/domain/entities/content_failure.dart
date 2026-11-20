// Project imports:
import 'package:interview_practice/core/error/failure.dart';
import 'package:interview_practice/features/content/domain/entities/content_issue.dart';

class ContentFailure extends Failure {
  final List<ContentIssue> issues;

  ContentFailure(this.issues);

  @override
  List<Object> get props => [issues];
}
