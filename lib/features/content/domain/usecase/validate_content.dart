// Project imports:
import 'package:interview_practice/features/content/domain/entities/content_catalog.dart';
import 'package:interview_practice/features/content/domain/entities/content_issue.dart';
import 'package:interview_practice/features/content/domain/entities/localized_text.dart';
import 'package:interview_practice/features/content/domain/entities/question.dart';

/// Semantic checks on parsed content. Pure Dart so `tool/validate_content.dart`
/// runs the exact same rules as the app.
class ValidateContent {
  const ValidateContent();

  List<ContentIssue> call(ContentCatalog catalog) {
    final issues = <ContentIssue>[];
    _checkTracks(catalog, issues);
    _checkQuestions(catalog, issues);
    _checkSets(catalog, issues);
    _checkPositions(catalog, issues);
    return issues;
  }

  void _checkTracks(ContentCatalog catalog, List<ContentIssue> issues) {
    final trackIds = <String>{};
    for (final track in catalog.tracks) {
      final path = 'tracks.json › ${track.id}';
      if (!trackIds.add(track.id)) {
        issues.add(_issue(ContentIssueCode.duplicateId, path, track.id));
      }
      _checkText(track.name, '$path.name', issues);

      final topicIds = <String>{};
      for (final topic in track.topics) {
        if (!topicIds.add(topic.id)) {
          issues.add(_issue(ContentIssueCode.duplicateId, path, topic.id));
        }
        _checkText(topic.name, '$path.${topic.id}', issues);
      }
    }
  }

  void _checkQuestions(ContentCatalog catalog, List<ContentIssue> issues) {
    final questionIds = <String>{};
    for (final question in catalog.questions) {
      final path = '${question.trackId}/questions.json › ${question.id}';
      if (!questionIds.add(question.id)) {
        issues.add(_issue(ContentIssueCode.duplicateId, path, question.id));
      }
      if (question.contentVersion < 1) {
        issues.add(
          _issue(
            ContentIssueCode.invalidVersion,
            path,
            '${question.contentVersion}',
          ),
        );
      }

      final track = catalog.trackById(question.trackId);
      if (track == null) {
        issues.add(
          _issue(ContentIssueCode.missingReference, path, question.trackId),
        );
      } else if (track.topicById(question.topicId) == null) {
        issues.add(
          _issue(ContentIssueCode.missingReference, path, question.topicId),
        );
      }

      _checkText(question.prompt, '$path.prompt', issues);
      if (!question.explanation.hasLanguage(LocalizedText.defaultLanguage)) {
        issues.add(_issue(ContentIssueCode.missingExplanation, path));
      }

      if (question.type.isAutoGraded) {
        _checkOptions(question, path, issues);
      } else if (question.keyPoints.isEmpty) {
        issues.add(_issue(ContentIssueCode.missingKeyPoints, path));
      } else {
        for (var i = 0; i < question.keyPoints.length; i++) {
          _checkText(question.keyPoints[i], '$path.keyPoints[$i]', issues);
        }
      }
    }
  }

  void _checkOptions(
    Question question,
    String path,
    List<ContentIssue> issues,
  ) {
    if (question.options.length < 2) {
      issues.add(_issue(ContentIssueCode.missingOptions, path));
    }
    final optionIds = <String>{};
    for (final option in question.options) {
      if (!optionIds.add(option.id)) {
        issues.add(_issue(ContentIssueCode.duplicateId, path, option.id));
      }
      _checkText(option.text, '$path.options.${option.id}', issues);
    }
    final answerId = question.answerId;
    if (answerId == null || !optionIds.contains(answerId)) {
      issues.add(
        _issue(ContentIssueCode.invalidAnswer, path, answerId ?? 'null'),
      );
    }
  }

  void _checkSets(ContentCatalog catalog, List<ContentIssue> issues) {
    final setIds = <String>{};
    for (final set in catalog.sets) {
      final path = '${set.trackId}/sets.json › ${set.id}';
      if (!setIds.add(set.id)) {
        issues.add(_issue(ContentIssueCode.duplicateId, path, set.id));
      }
      if (catalog.trackById(set.trackId) == null) {
        issues.add(
          _issue(ContentIssueCode.missingReference, path, set.trackId),
        );
      }
      _checkText(set.title, '$path.title', issues);
      if (set.questionIds.isEmpty) {
        issues.add(_issue(ContentIssueCode.emptySet, path));
      }

      final seen = <String>{};
      for (final questionId in set.questionIds) {
        if (!seen.add(questionId)) {
          issues.add(_issue(ContentIssueCode.duplicateId, path, questionId));
        }
        final question = catalog.questionById(questionId);
        if (question == null) {
          issues.add(
            _issue(ContentIssueCode.missingReference, path, questionId),
          );
        } else if (question.trackId != set.trackId) {
          issues.add(
            _issue(ContentIssueCode.trackMismatch, path, questionId),
          );
        } else if (set.isFree && question.level.isPremium) {
          issues.add(
            _issue(ContentIssueCode.premiumLevelInFreeSet, path, questionId),
          );
        }
      }
    }
  }

  /// Positions may only reference available tracks.
  void _checkPositions(ContentCatalog catalog, List<ContentIssue> issues) {
    final positionIds = <String>{};
    for (final position in catalog.positions) {
      final path = 'positions.json › ${position.id}';
      if (!positionIds.add(position.id)) {
        issues.add(_issue(ContentIssueCode.duplicateId, path, position.id));
      }
      _checkText(position.name, '$path.name', issues);
      if (position.options.isEmpty) {
        issues.add(_issue(ContentIssueCode.emptySet, path));
      }
      final optionIds = <String>{};
      final referenced = <String>[...position.coreTrackIds];
      for (final option in position.options) {
        if (!optionIds.add(option.id)) {
          issues.add(_issue(ContentIssueCode.duplicateId, path, option.id));
        }
        _checkText(option.name, '$path.${option.id}', issues);
        referenced.addAll(option.trackIds);
      }
      for (final trackId in referenced.toSet()) {
        if (catalog.trackById(trackId)?.isAvailable != true) {
          issues.add(
            _issue(ContentIssueCode.missingReference, path, trackId),
          );
        }
      }
    }
  }

  void _checkText(LocalizedText text, String path, List<ContentIssue> issues) {
    if (!text.hasLanguage(LocalizedText.defaultLanguage)) {
      issues.add(
        _issue(
          ContentIssueCode.missingTranslation,
          path,
          LocalizedText.defaultLanguage,
        ),
      );
    }
  }

  ContentIssue _issue(
    ContentIssueCode code,
    String path, [
    String detail = '',
  ]) =>
      ContentIssue(code: code, path: path, detail: detail);
}
