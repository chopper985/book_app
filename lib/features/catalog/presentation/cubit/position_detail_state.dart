part of 'position_detail_cubit.dart';

sealed class PositionDetailState extends Equatable {
  const PositionDetailState();

  @override
  List<Object?> get props => [];
}

final class PositionDetailLoading extends PositionDetailState {
  const PositionDetailLoading();
}

final class PositionDetailNotFound extends PositionDetailState {
  const PositionDetailNotFound();
}

final class PositionDetailLoaded extends PositionDetailState {
  final PositionDetail detail;

  const PositionDetailLoaded(this.detail);

  @override
  List<Object?> get props => [detail];
}
