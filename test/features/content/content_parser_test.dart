// Package imports:
import 'package:flutter_test/flutter_test.dart';

// Project imports:
import 'package:AppName/features/content/data/parsers/content_parser.dart';
import 'package:AppName/features/content/domain/entities/content_issue.dart';
import 'package:AppName/features/content/domain/entities/question.dart';
import 'content_test_data.dart';

void main() {
  const parser = ContentParser();

  test('parses valid content and skips files of unavailable tracks', () async {
    final parsed = await parser.parse(readerOf(files()));

    expect(parsed.issues, isEmpty);
    expect(parsed.catalog.tracks.map((track) => track.id), ['dart', 'go']);
    expect(parsed.catalog.availableTracks.map((track) => track.id), ['dart']);

    final question = parsed.catalog.questionById('dart.q1')!;
    expect(question.type, QuestionType.multipleChoice);
    expect(question.options.first.text.resolve('vi'), 'A');
    expect(question.options.first.text.resolve('en'), 'A');
    expect(parsed.catalog.questionById('dart.q2')!.keyPoints, hasLength(1));
  });

  test('reports a missing file', () async {
    final data = files()..remove('dart/sets.json');
    final parsed = await parser.parse(readerOf(data));

    expect(parsed.issues.single.code, ContentIssueCode.missingFile);
    expect(parsed.issues.single.path, 'dart/sets.json');
  });

  test('reports broken JSON', () async {
    final data = files()..['dart/questions.json'] = '{"questions": [';
    final parsed = await parser.parse(readerOf(data));

    expect(parsed.issues.single.code, ContentIssueCode.invalidFormat);
    expect(parsed.issues.single.path, 'dart/questions.json');
  });

  test('reports a bad item with its id and keeps the others', () async {
    final broken = choiceQuestion(id: 'dart.bad')..['level'] = 'expert';
    final parsed = await parser.parse(
      readerOf(files(questions: [broken, explainQuestion()])),
    );

    final issue = parsed.issues.single;
    expect(issue.code, ContentIssueCode.invalidFormat);
    expect(issue.path, 'dart/questions.json › dart.bad');
    expect(issue.detail, contains('level'));
    expect(parsed.catalog.questions.map((q) => q.id), ['dart.q2']);
  });
}
