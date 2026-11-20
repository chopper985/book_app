// Package imports:
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

// Project imports:
import 'package:interview_practice/features/practice/domain/entities/practice_bundle.dart';
import 'package:interview_practice/features/practice/domain/usecase/practice_usecases.dart';

part 'result_state.dart';

@injectable
class ResultCubit extends Cubit<ResultState> {
  final GetPracticeResult _getPracticeResult;

  ResultCubit(this._getPracticeResult) : super(const ResultLoading());

  Future<void> load(String sessionId) async {
    emit(const ResultLoading());
    final result = await _getPracticeResult(sessionId);
    final bundle = result.value;
    emit(bundle == null ? const ResultNotFound() : ResultLoaded(bundle));
  }

  /// Self-check of a self-explain question: ticks one key point.
  void toggleKeyPoint(String questionId, int index) {
    final current = state;
    if (current is! ResultLoaded) return;
    final checked = {...?current.checkedPoints[questionId]};
    if (!checked.remove(index)) checked.add(index);
    emit(
      ResultLoaded(
        current.bundle,
        checkedPoints: {...current.checkedPoints, questionId: checked},
      ),
    );
  }
}
