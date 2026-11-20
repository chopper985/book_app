// Dart imports:
import 'dart:convert';

// Project imports:
import 'package:interview_practice/features/content/data/models/question_model.dart';
import 'package:interview_practice/features/content/data/models/quiz_set_model.dart';
import 'package:interview_practice/features/content/data/models/position_model.dart';
import 'package:interview_practice/features/content/data/models/track_model.dart';
import 'package:interview_practice/features/content/domain/entities/content_catalog.dart';
import 'package:interview_practice/features/content/domain/entities/content_issue.dart';
import 'package:interview_practice/features/content/domain/entities/question.dart';
import 'package:interview_practice/features/content/domain/entities/quiz_set.dart';
import 'package:interview_practice/features/content/domain/entities/position.dart';
import 'package:interview_practice/features/content/domain/entities/track.dart';

/// Reads a content file relative to the content root, `null` when missing.
typedef ContentFileReader = Future<String?> Function(String relativePath);

class ParsedContent {
  final ContentCatalog catalog;
  final List<ContentIssue> issues;

  const ParsedContent({required this.catalog, required this.issues});
}

/// Turns the raw JSON files into a [ContentCatalog].
///
/// Layout: `tracks.json`, then `<trackId>/questions.json` and
/// `<trackId>/sets.json` for every available track. A broken item is reported
/// and skipped so one run lists every problem. Pure Dart: shared with
/// `tool/validate_content.dart`.
class ContentParser {
  static const String tracksFile = 'tracks.json';

  const ContentParser();

  static String questionsFile(String trackId) => '$trackId/questions.json';

  static String setsFile(String trackId) => '$trackId/sets.json';

  /// Optional: content without positions only offers language roadmaps.
  static const String positionsFile = 'positions.json';

  Future<ParsedContent> parse(ContentFileReader read) async {
    final issues = <ContentIssue>[];

    final tracks = await _readItems<Track>(
      read,
      tracksFile,
      'tracks',
      TrackModel.fromJson,
      issues,
    );
    final questions = <Question>[];
    final sets = <QuizSet>[];

    for (final track in tracks.where((track) => track.isAvailable)) {
      questions.addAll(
        await _readItems(
          read,
          questionsFile(track.id),
          'questions',
          QuestionModel.fromJson,
          issues,
        ),
      );
      sets.addAll(
        await _readItems(
          read,
          setsFile(track.id),
          'sets',
          QuizSetModel.fromJson,
          issues,
        ),
      );
    }

    final positions = await read(positionsFile) == null
        ? const <Position>[]
        : await _readItems(
            read,
            positionsFile,
            'positions',
            PositionModel.fromJson,
            issues,
          );

    return ParsedContent(
      catalog: ContentCatalog(
        tracks: tracks,
        questions: questions,
        sets: sets,
        positions: positions,
      ),
      issues: issues,
    );
  }

  Future<List<T>> _readItems<T>(
    ContentFileReader read,
    String file,
    String key,
    T Function(Object? json) fromJson,
    List<ContentIssue> issues,
  ) async {
    final raw = await read(file);
    if (raw == null) {
      issues.add(ContentIssue(code: ContentIssueCode.missingFile, path: file));
      return const [];
    }

    final Object? decoded;
    try {
      decoded = jsonDecode(raw);
    } on FormatException catch (error) {
      issues.add(
        ContentIssue(
          code: ContentIssueCode.invalidFormat,
          path: file,
          detail: error.message,
        ),
      );
      return const [];
    }

    final items = decoded is Map<String, dynamic> ? decoded[key] : null;
    if (items is! List) {
      issues.add(
        ContentIssue(
          code: ContentIssueCode.invalidFormat,
          path: file,
          detail: '"$key" must be a list',
        ),
      );
      return const [];
    }

    final result = <T>[];
    for (var i = 0; i < items.length; i++) {
      try {
        result.add(fromJson(items[i]));
      } on Exception catch (error) {
        final item = items[i];
        final id = item is Map && item['id'] is String ? item['id'] : '#$i';
        issues.add(
          ContentIssue(
            code: ContentIssueCode.invalidFormat,
            path: '$file › $id',
            detail: '$error',
          ),
        );
      }
    }
    return result;
  }
}
