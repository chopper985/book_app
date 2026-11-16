// Package imports:
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

// Project imports:
import 'package:AppName/features/catalog/domain/entities/quiz_set_summary.dart';
import 'package:AppName/features/catalog/domain/entities/track_detail.dart';
import 'package:AppName/features/catalog/domain/usecase/filter_quiz_sets.dart';
import 'package:AppName/features/catalog/domain/usecase/get_track_detail.dart';
import 'package:AppName/features/content/domain/entities/content_failure.dart';
import 'package:AppName/features/content/domain/entities/content_issue.dart';
import 'package:AppName/features/content/domain/entities/question.dart';

part 'track_detail_state.dart';

@injectable
class TrackDetailCubit extends Cubit<TrackDetailState> {
  final GetTrackDetail _getTrackDetail;
  final FilterQuizSets _filterQuizSets = const FilterQuizSets();

  TrackDetailCubit(this._getTrackDetail) : super(const TrackDetailLoading());

  Future<void> load(String trackId) async {
    emit(const TrackDetailLoading());
    final result = await _getTrackDetail(trackId);
    final detail = result.value;
    if (detail != null) {
      emit(_loaded(detail));
      return;
    }
    final error = result.error;
    emit(
      error is ContentFailure
          ? TrackDetailInvalidContent(error.issues)
          : const TrackDetailNotFound(),
    );
  }

  void selectTopic(String? topicId) {
    final current = state;
    if (current is! TrackDetailLoaded) return;
    emit(_loaded(current.detail, topicId: topicId, level: current.level));
  }

  void selectLevel(QuestionLevel? level) {
    final current = state;
    if (current is! TrackDetailLoaded) return;
    emit(_loaded(current.detail, topicId: current.topicId, level: level));
  }

  TrackDetailLoaded _loaded(
    TrackDetail detail, {
    String? topicId,
    QuestionLevel? level,
  }) {
    return TrackDetailLoaded(
      detail: detail,
      topicId: topicId,
      level: level,
      visibleSets: _filterQuizSets(
        detail.sets,
        topicId: topicId,
        level: level,
      ),
    );
  }
}
