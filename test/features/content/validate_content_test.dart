// Package imports:
import 'package:flutter_test/flutter_test.dart';

// Project imports:
import 'package:AppName/features/content/data/parsers/content_parser.dart';
import 'package:AppName/features/content/domain/entities/content_issue.dart';
import 'package:AppName/features/content/domain/usecase/validate_content.dart';
import 'content_test_data.dart';

Future<List<ContentIssue>> validate(Map<String, String> data) async {
  final parsed = await const ContentParser().parse(readerOf(data));
  expect(parsed.issues, isEmpty, reason: 'fixture must parse');
  return const ValidateContent()(parsed.catalog);
}

void main() {
  test('valid content has no issues', () async {
    expect(await validate(files()), isEmpty);
  });

  test('duplicate question id', () async {
    final issues = await validate(
      files(questions: [choiceQuestion(), choiceQuestion(), explainQuestion()]),
    );
    expect(issues.single.code, ContentIssueCode.duplicateId);
    expect(issues.single.detail, 'dart.q1');
  });

  test('set references a missing question', () async {
    final issues = await validate(
      files(sets: [set(questionIds: ['dart.q1', 'dart.missing'])]),
    );
    expect(issues.single.code, ContentIssueCode.missingReference);
    expect(issues.single.detail, 'dart.missing');
  });

  test('question references a missing topic', () async {
    final issues = await validate(
      files(
        questions: [choiceQuestion()..['topicId'] = 'nope', explainQuestion()],
      ),
    );
    expect(issues.single.code, ContentIssueCode.missingReference);
    expect(issues.single.detail, 'nope');
  });

  test('answer points to an option that does not exist', () async {
    final issues = await validate(
      files(
        questions: [choiceQuestion()..['answerId'] = 'z', explainQuestion()],
      ),
    );
    expect(issues.single.code, ContentIssueCode.invalidAnswer);
    expect(issues.single.detail, 'z');
  });

  test('missing explanation', () async {
    final issues = await validate(
      files(
        questions: [choiceQuestion()..remove('explanation'), explainQuestion()],
      ),
    );
    expect(issues.single.code, ContentIssueCode.missingExplanation);
  });

  test('self-explain question without key points', () async {
    final issues = await validate(
      files(
        questions: [choiceQuestion(), explainQuestion()..remove('keyPoints')],
      ),
    );
    expect(issues.single.code, ContentIssueCode.missingKeyPoints);
  });

  test('text without Vietnamese', () async {
    final issues = await validate(
      files(
        questions: [
          choiceQuestion()..['prompt'] = {'en': 'Question?'},
          explainQuestion(),
        ],
      ),
    );
    expect(issues.single.code, ContentIssueCode.missingTranslation);
    expect(issues.single.path, endsWith('dart.q1.prompt'));
  });

  group('premium levels', () {
    test('a free set must not contain Middle/Senior questions', () async {
      final issues = await validate(
        files(
          questions: [
            choiceQuestion()..['level'] = 'middle',
            explainQuestion()..['level'] = 'senior',
          ],
        ),
      );
      expect(
        issues.map((issue) => (issue.code, issue.detail)),
        [
          (ContentIssueCode.premiumLevelInFreeSet, 'dart.q1'),
          (ContentIssueCode.premiumLevelInFreeSet, 'dart.q2'),
        ],
      );
    });

    test('a paid set may contain them', () async {
      final issues = await validate(
        files(
          questions: [
            choiceQuestion()..['level'] = 'middle',
            explainQuestion(),
          ],
          sets: [set()..['accessPlanId'] = 'premium'],
        ),
      );
      expect(issues, isEmpty);
    });
  });
}
