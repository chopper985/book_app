// Dart imports:
import 'dart:async';

// Package imports:
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

// Project imports:
import 'package:interview_practice/features/auth/domain/entities/auth_failure.dart';
import 'package:interview_practice/features/auth/domain/entities/auth_user.dart';
import 'package:interview_practice/features/auth/domain/usecase/account_usecases.dart';

part 'auth_state.dart';

/// App-wide account state: who is signed in, sign-out and deletion.
@injectable
class AuthCubit extends Cubit<AuthState> {
  final SignOut _signOut;
  final DeleteAccount _deleteAccount;
  late final StreamSubscription<AuthUser?> _subscription;

  AuthCubit(WatchAuthUser watch, this._signOut, this._deleteAccount)
      : super(AuthState(user: watch.current)) {
    _subscription = watch().listen(
      (user) => emit(AuthState(user: user, busy: state.busy)),
    );
  }

  Future<void> signOut() async {
    emit(AuthState(user: state.user, busy: true));
    await _signOut();
    emit(AuthState(user: state.user));
  }

  /// `null` when deleted; otherwise why it could not be.
  Future<AuthFailure?> deleteAccount() async {
    emit(AuthState(user: state.user, busy: true));
    final failure = await _deleteAccount();
    emit(AuthState(user: state.user));
    return failure;
  }

  @override
  Future<void> close() async {
    await _subscription.cancel();
    return super.close();
  }
}
