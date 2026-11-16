// Project imports:
import 'package:AppName/core/error/failure.dart';
import 'package:AppName/features/content/domain/entities/content_issue.dart';

class ContentFailure extends Failure {
  final List<ContentIssue> issues;

  ContentFailure(this.issues);

  @override
  List<Object> get props => [issues];
}
