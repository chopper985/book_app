// Dart imports:
import 'dart:convert';

/// Minimal valid content; tests mutate copies of it to trigger each issue.
Map<String, Object?> validTracks() => {
      'tracks': [
        {
          'id': 'dart',
          'name': {'vi': 'Dart'},
          'order': 1,
          'available': true,
          'topics': [
            {
              'id': 'null_safety',
              'name': {'vi': 'Null safety'},
            },
          ],
        },
        {
          'id': 'go',
          'name': {'vi': 'Go Backend'},
          'order': 2,
          'available': false,
          'topics': [],
        },
      ],
    };

Map<String, Object?> choiceQuestion({String id = 'dart.q1'}) => {
      'id': id,
      'contentVersion': 1,
      'trackId': 'dart',
      'topicId': 'null_safety',
      'level': 'fresher',
      'type': 'multipleChoice',
      'prompt': {'vi': 'Câu hỏi?'},
      'options': [
        {'id': 'a', 'text': 'A'},
        {
          'id': 'b',
          'text': {'vi': 'B'},
        },
      ],
      'answerId': 'a',
      'explanation': {'vi': 'Lời giải'},
    };

Map<String, Object?> explainQuestion({String id = 'dart.q2'}) => {
      'id': id,
      'contentVersion': 1,
      'trackId': 'dart',
      'topicId': 'null_safety',
      'level': 'junior',
      'type': 'selfExplain',
      'prompt': {'vi': 'Giải thích?'},
      'keyPoints': [
        {'vi': 'Ý 1'},
      ],
      'explanation': {'vi': 'Lời giải'},
    };

Map<String, Object?> set({
  String id = 'dart.set1',
  List<String> questionIds = const ['dart.q1', 'dart.q2'],
}) =>
    {
      'id': id,
      'trackId': 'dart',
      'title': {'vi': 'Bộ đề'},
      'questionIds': questionIds,
    };

/// In-memory content files keyed by relative path.
Map<String, String> files({
  Map<String, Object?>? tracks,
  List<Map<String, Object?>>? questions,
  List<Map<String, Object?>>? sets,
}) =>
    {
      'tracks.json': jsonEncode(tracks ?? validTracks()),
      'dart/questions.json': jsonEncode({
        'questions': questions ?? [choiceQuestion(), explainQuestion()],
      }),
      'dart/sets.json': jsonEncode({
        'sets': sets ?? [set()],
      }),
    };

Future<String?> Function(String) readerOf(Map<String, String> files) =>
    (path) async => files[path];
