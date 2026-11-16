// Package imports:
import 'package:equatable/equatable.dart';

// Project imports:
import 'package:AppName/features/content/domain/entities/question.dart';
import 'package:AppName/features/content/domain/entities/quiz_set.dart';
import 'package:AppName/features/content/domain/entities/track.dart';
import 'package:AppName/features/practice/domain/entities/practice_session.dart';
import 'package:AppName/features/practice/domain/entities/session_result.dart';

/// A session with the content it needs to render.
class PracticeBundle extends Equatable {
  final PracticeSession session;
  final QuizSet set;
  final Track track;

  /// Questions in session order.
  final List<Question> questions;

  const PracticeBundle({
    required this.session,
    required this.set,
    required this.track,
    required this.questions,
  });

  Question get currentQuestion => questions[session.currentIndex];

  PracticeBundle withSession(PracticeSession session) => PracticeBundle(
        session: session,
        set: set,
        track: track,
        questions: questions,
      );

  @override
  List<Object?> get props => [session, set, track, questions];
}

/// A graded session with its questions.
class ResultBundle extends Equatable {
  final SessionResult result;
  final QuizSet set;
  final Track track;
  final Map<String, Question> questions;

  const ResultBundle({
    required this.result,
    required this.set,
    required this.track,
    required this.questions,
  });

  @override
  List<Object?> get props => [result, set, track, questions];
}
