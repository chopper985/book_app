// Dart imports:
import 'dart:async';

// Package imports:
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

// Project imports:
import 'package:AppName/features/catalog/domain/entities/explore_dashboard.dart';
import 'package:AppName/features/catalog/domain/usecase/get_explore_data.dart';
import 'package:AppName/features/content/domain/entities/content_failure.dart';
import 'package:AppName/features/content/domain/entities/content_issue.dart';
import 'package:AppName/features/practice/domain/entities/practice_hub.dart';
import 'package:AppName/features/practice/domain/usecase/get_practice_hub.dart';

part 'practice_hub_state.dart';

@injectable
class PracticeHubCubit extends Cubit<PracticeHubState> {
  final GetPracticeHub _getHub;
  final GetExploreDashboard _getDashboard;
  late final StreamSubscription<void> _progressSubscription;

  PracticeHubCubit(this._getHub, this._getDashboard, WatchProgress watch)
      : super(const PracticeHubLoading()) {
    _progressSubscription = watch().listen((_) => refresh());
  }

  Future<void> load() async {
    emit(const PracticeHubLoading());
    await _emitLoaded();
  }

  /// Reloads after practice without showing the loading state.
  Future<void> refresh() async {
    if (state is PracticeHubLoaded) await _emitLoaded();
  }

  Future<void> _emitLoaded() async {
    final result = await _getHub();
    final hub = result.value;
    if (hub == null) {
      final error = result.error;
      if (!isClosed) {
        emit(
          PracticeHubInvalidContent(
            error is ContentFailure ? error.issues : const [],
          ),
        );
      }
      return;
    }
    final dashboard = await _getDashboard();
    if (!isClosed) {
      emit(PracticeHubLoaded(hub: hub, learner: dashboard.learner));
    }
  }

  @override
  Future<void> close() async {
    await _progressSubscription.cancel();
    return super.close();
  }
}
