part of 'sign_in_cubit.dart';

enum SignInStep { phone, code }

class SignInState extends Equatable {
  final SignInStep step;
  final String phone;
  final String code;
  final String? verificationId;
  final int? resendToken;

  /// Seconds before "resend code" is allowed again.
  final int resendSeconds;
  final bool busy;
  final AuthFailure? failure;

  /// Signed in; the screen closes.
  final bool done;

  /// Signed in to an existing account while the device holds this many
  /// guest practice sessions: ask whether to merge them.
  final int? guestSessions;

  const SignInState({
    this.step = SignInStep.phone,
    this.phone = '',
    this.code = '',
    this.verificationId,
    this.resendToken,
    this.resendSeconds = 0,
    this.busy = false,
    this.failure,
    this.done = false,
    this.guestSessions,
  });

  bool get canSendCode => !busy && phone.trim().isNotEmpty;

  bool get canResend => !busy && resendSeconds == 0;

  bool get canConfirm => !busy && code.length == 6;

  SignInState copyWith({
    SignInStep? step,
    String? phone,
    String? code,
    String? Function()? verificationId,
    int? Function()? resendToken,
    int? resendSeconds,
    bool? busy,
    AuthFailure? Function()? failure,
    bool? done,
    int? Function()? guestSessions,
  }) {
    return SignInState(
      step: step ?? this.step,
      phone: phone ?? this.phone,
      code: code ?? this.code,
      verificationId:
          verificationId == null ? this.verificationId : verificationId(),
      resendToken: resendToken == null ? this.resendToken : resendToken(),
      resendSeconds: resendSeconds ?? this.resendSeconds,
      busy: busy ?? this.busy,
      failure: failure == null ? this.failure : failure(),
      done: done ?? this.done,
      guestSessions:
          guestSessions == null ? this.guestSessions : guestSessions(),
    );
  }

  @override
  List<Object?> get props => [
        step,
        phone,
        code,
        verificationId,
        resendToken,
        resendSeconds,
        busy,
        failure,
        done,
        guestSessions,
      ];
}
