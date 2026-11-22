part of 'auth_cubit.dart';

class AuthState extends Equatable {
  /// `null` before Firebase answers or when it is not configured.
  final AuthUser? user;

  /// Sign-out or deletion in progress.
  final bool busy;

  const AuthState({this.user, this.busy = false});

  bool get isLinked => user?.isLinked ?? false;

  @override
  List<Object?> get props => [user, busy];
}
