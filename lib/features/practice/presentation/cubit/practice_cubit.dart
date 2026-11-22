// Package imports:
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

// Project imports:
import 'package:interview_practice/core/analytics/app_analytics.dart';
import 'package:interview_practice/features/practice/domain/entities/practice_bundle.dart';
import 'package:interview_practice/features/practice/domain/entities/practice_session.dart';
import 'package:interview_practice/features/practice/domain/repositories/practice_gate.dart';
import 'package:interview_practice/features/practice/domain/usecase/practice_usecases.dart';

part 'practice_state.dart';

@injectable
class PracticeCubit extends Cubit<PracticeState> {
  final StartPractice _startPractice;
  final ResumePractice _resumePractice;
  final SavePractice _savePractice;
  final SubmitPractice _submitPractice;
  final AppAnalytics _analytics;

  bool _submitting = false;

  PracticeCubit(
    this._startPractice,
    this._resumePractice,
    this._savePractice,
    this._submitPractice, {
    AppAnalytics analytics = const NoopAppAnalytics(),
  })  : _analytics = analytics,
        super(const PracticeLoading());

  /// Resumes [sessionId] when given and still open, otherwise starts a new
  /// session of [setId].
  Future<void> start(
    String setId, {
    List<String>? onlyQuestionIds,
    String? sessionId,
  }) async {
    emit(const PracticeLoading());
    final resumed =
        sessionId == null ? null : (await _resumePractice(sessionId)).value;
    var bundle = resumed;
    if (bundle == null) {
      final started =
          await _startPractice(setId, onlyQuestionIds: onlyQuestionIds);
      if (started.error case PracticeLockedFailure(:final reason)) {
        emit(PracticeLocked(reason));
        return;
      }
      bundle = started.value;
    }
    if (bundle != null) {
      _analytics.practiceStarted(
        trackId: bundle.track.id,
        setId: bundle.set.id,
        mode: resumed != null
            ? PracticeMode.resume
            : onlyQuestionIds != null
                ? PracticeMode.subset
                : PracticeMode.full,
        questionCount: bundle.questions.length,
      );
    }
    emit(
      bundle == null ? const PracticeNotFound() : PracticeInProgress(bundle),
    );
  }

  void selectOption(String optionId) {
    _update((bundle) {
      final session = bundle.session;
      return session.copyWith(
        answers: {...session.answers, session.currentQuestionId: optionId},
      );
    });
  }

  void toggleFlag() {
    _update((bundle) {
      final session = bundle.session;
      final id = session.currentQuestionId;
      final flagged = {...session.flagged};
      if (!flagged.remove(id)) flagged.add(id);
      return session.copyWith(flagged: flagged);
    });
  }

  void goTo(int index) {
    _update((bundle) {
      final last = bundle.session.questionIds.length - 1;
      return bundle.session.copyWith(currentIndex: index.clamp(0, last));
    });
  }

  void next() => goTo(_currentIndex + 1);

  void previous() => goTo(_currentIndex - 1);

  /// Submits once. A manual submit racing the timer produces one result.
  Future<void> submit({bool timedOut = false}) async {
    final current = state;
    if (current is! PracticeInProgress || _submitting) return;
    _submitting = true;

    await _savePractice(current.bundle.session);
    final result = await _submitPractice(
      current.bundle.session.id,
      timedOut: timedOut,
    );
    if (result.value case final bundle?) {
      final graded = bundle.result;
      _analytics.practiceSubmitted(
        trackId: graded.trackId,
        setId: graded.setId,
        scorePercent: graded.scorePercent,
        questionCount: graded.items.length,
        durationSeconds: graded.duration.inSeconds,
        timedOut: graded.timedOut,
      );
      emit(PracticeSubmitted(current.bundle.session.id));
    } else {
      _submitting = false;
    }
  }

  int get _currentIndex {
    final current = state;
    return current is PracticeInProgress
        ? current.bundle.session.currentIndex
        : 0;
  }

  void _update(PracticeSession Function(PracticeBundle bundle) change) {
    final current = state;
    if (current is! PracticeInProgress || _submitting) return;
    final session = change(current.bundle);
    final bundle = current.bundle.withSession(session);
    emit(PracticeInProgress(bundle));
    _savePractice(session);
  }
}
