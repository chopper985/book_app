// Dart imports:
import 'dart:async';

// Package imports:
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

// Project imports:
import 'package:interview_practice/features/auth/domain/entities/auth_failure.dart';
import 'package:interview_practice/features/auth/domain/entities/auth_results.dart';
import 'package:interview_practice/features/auth/domain/usecase/account_usecases.dart';

part 'sign_in_state.dart';

/// Google sign-in and the two-step phone flow (number, then SMS code).
@injectable
class SignInCubit extends Cubit<SignInState> {
  static const int resendDelaySeconds = 60;

  final SignInWithGoogle _signInWithGoogle;
  final RequestPhoneCode _requestPhoneCode;
  final ConfirmPhoneCode _confirmPhoneCode;
  Timer? _countdown;

  SignInCubit(
    this._signInWithGoogle,
    this._requestPhoneCode,
    this._confirmPhoneCode,
  ) : super(const SignInState());

  Future<void> signInWithGoogle() async {
    if (state.busy) return;
    emit(state.copyWith(busy: true, failure: () => null));
    _handle(await _signInWithGoogle());
  }

  void setPhone(String phone) =>
      emit(state.copyWith(phone: phone, failure: () => null));

  Future<void> sendCode() async {
    if (!state.canSendCode) return;
    await _request();
  }

  Future<void> resendCode() async {
    if (!state.canResend) return;
    await _request(resendToken: state.resendToken);
  }

  /// Submits automatically once 6 digits are typed.
  Future<void> setCode(String code) async {
    emit(state.copyWith(code: code, failure: () => null));
    if (code.length == 6) await confirmCode();
  }

  Future<void> confirmCode() async {
    final verificationId = state.verificationId;
    if (verificationId == null || !state.canConfirm) return;
    emit(state.copyWith(busy: true, failure: () => null));
    _handle(await _confirmPhoneCode(verificationId, state.code));
  }

  /// Back to the phone number step.
  void editPhone() {
    _countdown?.cancel();
    emit(
      state.copyWith(
        step: SignInStep.phone,
        verificationId: () => null,
        resendSeconds: 0,
        failure: () => null,
      ),
    );
  }

  Future<void> _request({int? resendToken}) async {
    emit(state.copyWith(busy: true, failure: () => null));
    final result =
        await _requestPhoneCode(state.phone, resendToken: resendToken);
    if (isClosed) return;
    switch (result) {
      case PhoneCodeSent(:final verificationId, :final resendToken):
        emit(
          state.copyWith(
            step: SignInStep.code,
            code: '',
            verificationId: () => verificationId,
            resendToken: () => resendToken,
            busy: false,
          ),
        );
        _startCountdown();
      case PhoneAutoVerified():
        emit(state.copyWith(busy: false, done: true));
      case PhoneCodeFailed(:final failure):
        emit(state.copyWith(busy: false, failure: () => failure));
    }
  }

  void _handle(SignInResult result) {
    if (isClosed) return;
    switch (result) {
      case SignInSuccess():
        _countdown?.cancel();
        emit(state.copyWith(busy: false, done: true));
      case SignInCancelled():
        emit(state.copyWith(busy: false));
      case SignInFailed(:final failure):
        emit(state.copyWith(busy: false, failure: () => failure));
    }
  }

  void _startCountdown() {
    _countdown?.cancel();
    emit(state.copyWith(resendSeconds: resendDelaySeconds));
    _countdown = Timer.periodic(const Duration(seconds: 1), (timer) {
      final next = state.resendSeconds - 1;
      emit(state.copyWith(resendSeconds: next < 0 ? 0 : next));
      if (next <= 0) timer.cancel();
    });
  }

  @override
  Future<void> close() {
    _countdown?.cancel();
    return super.close();
  }
}
