// Package imports:
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

// Project imports:
import 'package:AppName/features/catalog/domain/entities/explore_dashboard.dart';
import 'package:AppName/features/catalog/domain/entities/track_overview.dart';
import 'package:AppName/features/catalog/domain/usecase/filter_tracks.dart';
import 'package:AppName/features/catalog/domain/usecase/get_explore_data.dart';
import 'package:AppName/features/content/domain/entities/content_failure.dart';
import 'package:AppName/features/content/domain/entities/content_issue.dart';

part 'explore_state.dart';

@injectable
class ExploreCubit extends Cubit<ExploreState> {
  final GetTracks _getTracks;
  final GetExploreDashboard _getDashboard;
  final FilterTracks _filterTracks = const FilterTracks();

  ExploreCubit(this._getTracks, this._getDashboard)
      : super(const ExploreLoading());

  Future<void> load() async {
    emit(const ExploreLoading());
    final result = await _getTracks();
    final tracks = result.value;
    if (tracks == null) {
      final error = result.error;
      emit(ExploreInvalidContent(error is ContentFailure ? error.issues : []));
      return;
    }
    emit(
      ExploreLoaded(
        tracks: tracks,
        visibleTracks: tracks,
        dashboard: await _getDashboard(),
      ),
    );
  }

  void selectCategory(String? category) {
    final current = state;
    if (current is! ExploreLoaded) return;
    emit(
      ExploreLoaded(
        tracks: current.tracks,
        dashboard: current.dashboard,
        category: category,
        visibleTracks: _filterTracks(current.tracks, category),
      ),
    );
  }
}
