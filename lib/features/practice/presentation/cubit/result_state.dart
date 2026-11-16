part of 'result_cubit.dart';

sealed class ResultState extends Equatable {
  const ResultState();

  @override
  List<Object?> get props => [];
}

final class ResultLoading extends ResultState {
  const ResultLoading();
}

final class ResultNotFound extends ResultState {
  const ResultNotFound();
}

final class ResultLoaded extends ResultState {
  final ResultBundle bundle;

  /// Ticked key points per self-explain question id.
  final Map<String, Set<int>> checkedPoints;

  const ResultLoaded(this.bundle, {this.checkedPoints = const {}});

  @override
  List<Object?> get props => [bundle, checkedPoints];
}
