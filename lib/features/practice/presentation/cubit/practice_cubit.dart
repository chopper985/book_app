// Package imports:
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

// Project imports:
import 'package:AppName/features/practice/domain/entities/practice_bundle.dart';
import 'package:AppName/features/practice/domain/entities/practice_session.dart';
import 'package:AppName/features/practice/domain/usecase/practice_usecases.dart';

part 'practice_state.dart';

@injectable
class PracticeCubit extends Cubit<PracticeState> {
  final StartPractice _startPractice;
  final SavePractice _savePractice;
  final SubmitPractice _submitPractice;

  bool _submitting = false;

  PracticeCubit(this._startPractice, this._savePractice, this._submitPractice)
      : super(const PracticeLoading());

  Future<void> start(String setId, {List<String>? onlyQuestionIds}) async {
    emit(const PracticeLoading());
    final result =
        await _startPractice(setId, onlyQuestionIds: onlyQuestionIds);
    final bundle = result.value;
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
    if (result.value != null) {
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
