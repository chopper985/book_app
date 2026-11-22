// Package imports:
import 'package:equatable/equatable.dart';

// Project imports:
import 'package:interview_practice/features/auth/domain/entities/auth_failure.dart';
import 'package:interview_practice/features/auth/domain/entities/auth_user.dart';

/// Outcome of a sign-in attempt.
sealed class SignInResult extends Equatable {
  const SignInResult();

  @override
  List<Object?> get props => [];
}

final class SignInSuccess extends SignInResult {
  final AuthUser user;

  /// The credential already belonged to another account, which is now
  /// signed in: local data must be merged into it.
  final bool switchedAccount;

  const SignInSuccess(this.user, {this.switchedAccount = false});

  @override
  List<Object?> get props => [user, switchedAccount];
}

final class SignInCancelled extends SignInResult {
  const SignInCancelled();
}

final class SignInFailed extends SignInResult {
  final AuthFailure failure;

  const SignInFailed(this.failure);

  @override
  List<Object?> get props => [failure];
}

/// Outcome of requesting an SMS code.
sealed class PhoneCodeRequest extends Equatable {
  const PhoneCodeRequest();

  @override
  List<Object?> get props => [];
}

final class PhoneCodeSent extends PhoneCodeRequest {
  final String verificationId;

  /// Lets "resend code" skip some checks; `null` on some platforms.
  final int? resendToken;

  const PhoneCodeSent(this.verificationId, {this.resendToken});

  @override
  List<Object?> get props => [verificationId, resendToken];
}

/// Android verified the SMS by itself: the learner is already signed in.
final class PhoneAutoVerified extends PhoneCodeRequest {
  final SignInSuccess result;

  const PhoneAutoVerified(this.result);

  @override
  List<Object?> get props => [result];
}

final class PhoneCodeFailed extends PhoneCodeRequest {
  final AuthFailure failure;

  const PhoneCodeFailed(this.failure);

  @override
  List<Object?> get props => [failure];
}
