// Project imports:
import 'package:AppName/features/practice/domain/entities/practice_session.dart';
import 'package:AppName/features/practice/domain/entities/session_result.dart';

/// JSON mapping of practice entities for local storage. Dates are stored as
/// UTC epoch milliseconds so they survive time zone changes.
class PracticeJson {
  const PracticeJson._();

  static Map<String, dynamic> session(PracticeSession session) => {
        'id': session.id,
        'setId': session.setId,
        'trackId': session.trackId,
        'questionIds': session.questionIds,
        'answers': session.answers,
        'flagged': session.flagged.toList(),
        'currentIndex': session.currentIndex,
        'startedAt': _date(session.startedAt),
        'updatedAt': _date(session.updatedAt),
        if (session.endsAt != null) 'endsAt': _date(session.endsAt!),
      };

  static PracticeSession sessionFrom(Map<String, dynamic> json) {
    final questionIds = List<String>.unmodifiable(json['questionIds'] as List);
    return PracticeSession(
      id: json['id'] as String,
      setId: json['setId'] as String,
      trackId: json['trackId'] as String,
      questionIds: questionIds,
      answers: Map<String, String>.from(json['answers'] as Map),
      flagged: Set<String>.from(json['flagged'] as List),
      currentIndex: (json['currentIndex'] as int)
          .clamp(0, questionIds.isEmpty ? 0 : questionIds.length - 1),
      startedAt: _dateFrom(json['startedAt'])!,
      updatedAt: _dateFrom(json['updatedAt']),
      endsAt: _dateFrom(json['endsAt']),
    );
  }

  static Map<String, dynamic> result(SessionResult result) => {
        'sessionId': result.sessionId,
        'setId': result.setId,
        'trackId': result.trackId,
        'startedAt': _date(result.startedAt),
        'submittedAt': _date(result.submittedAt),
        'timedOut': result.timedOut,
        'items': [
          for (final item in result.items)
            {
              'questionId': item.questionId,
              'contentVersion': item.contentVersion,
              'status': item.status.name,
              if (item.selectedOptionId != null)
                'selectedOptionId': item.selectedOptionId,
              if (item.correctOptionId != null)
                'correctOptionId': item.correctOptionId,
            },
        ],
      };

  static SessionResult resultFrom(Map<String, dynamic> json) => SessionResult(
        sessionId: json['sessionId'] as String,
        setId: json['setId'] as String,
        trackId: json['trackId'] as String,
        startedAt: _dateFrom(json['startedAt'])!,
        submittedAt: _dateFrom(json['submittedAt'])!,
        timedOut: json['timedOut'] as bool? ?? false,
        items: [
          for (final item in (json['items'] as List).cast<Map>())
            QuestionResult(
              questionId: item['questionId'] as String,
              contentVersion: item['contentVersion'] as int,
              status: AnswerStatus.values.byName(item['status'] as String),
              selectedOptionId: item['selectedOptionId'] as String?,
              correctOptionId: item['correctOptionId'] as String?,
            ),
        ],
      );

  static int _date(DateTime date) => date.toUtc().millisecondsSinceEpoch;

  static DateTime? _dateFrom(Object? value) => value is int
      ? DateTime.fromMillisecondsSinceEpoch(value, isUtc: true).toLocal()
      : null;
}
