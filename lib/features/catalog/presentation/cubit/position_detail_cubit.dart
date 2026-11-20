// Dart imports:
import 'dart:async';
import 'dart:math' as math;

// Package imports:
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

// Project imports:
import 'package:interview_practice/features/catalog/domain/entities/position_detail.dart';
import 'package:interview_practice/features/catalog/domain/entities/user_roadmap.dart';
import 'package:interview_practice/features/catalog/domain/usecase/get_explore_data.dart';
import 'package:interview_practice/features/catalog/domain/usecase/user_roadmaps.dart';
import 'package:interview_practice/features/content/domain/entities/content_catalog.dart';

part 'position_detail_state.dart';

/// A position roadmap in the Roadmaps tab.
@injectable
class PositionDetailCubit extends Cubit<PositionDetailState> {
  final GetPositionDetail _getPositionDetail;
  late final StreamSubscription<void> _subscription;
  UserRoadmap? _roadmap;

  PositionDetailCubit(this._getPositionDetail, WatchProgress watchProgress)
      : super(const PositionDetailLoading()) {
    _subscription = watchProgress().listen((_) => _reload());
  }

  Future<void> load(UserRoadmap roadmap) async {
    _roadmap = roadmap;
    emit(const PositionDetailLoading());
    await _reload();
  }

  Future<void> _reload() async {
    final roadmap = _roadmap;
    if (roadmap == null) return;
    final detail = (await _getPositionDetail(roadmap)).value;
    if (isClosed) return;
    emit(
      detail == null
          ? const PositionDetailNotFound()
          : PositionDetailLoaded(detail),
    );
  }

  /// Random questions of every track for one mock test, `null` to take the
  /// whole pool when it is small.
  static List<String>? pickMockQuestions(
    List<String> pool, [
    math.Random? random,
  ]) {
    const count = ContentCatalog.positionMockQuestions;
    if (pool.length <= count) return null;
    return ([...pool]..shuffle(random)).take(count).toList();
  }

  @override
  Future<void> close() async {
    await _subscription.cancel();
    return super.close();
  }
}
