// Project imports:
import 'package:interview_practice/features/auth/domain/entities/auth_failure.dart';
import 'package:interview_practice/features/auth/domain/entities/auth_results.dart';
import 'package:interview_practice/features/auth/domain/entities/auth_user.dart';

abstract class AuthRepository {
  AuthUser? get currentUser;

  Stream<AuthUser?> get userChanges;

  /// Signs in anonymously when no account exists yet, so every install has a
  /// uid to link later. No-op when Firebase is not configured.
  Future<void> ensureSignedIn();

  /// Links Google to the current (anonymous) account, or signs in to the
  /// existing account that already uses it.
  Future<SignInResult> signInWithGoogle();

  /// Sends an SMS code to [phoneNumber] in E.164 form (`+84912345678`).
  Future<PhoneCodeRequest> requestPhoneCode(
    String phoneNumber, {
    int? resendToken,
  });

  /// Links (or signs in with) the phone number using the received code.
  Future<SignInResult> confirmPhoneCode(String verificationId, String code);

  /// Signs out, then starts a fresh anonymous account.
  Future<void> signOut();

  /// Deletes the account itself (cloud data is removed by the caller first).
  /// Returns a failure with [AuthFailureCode.requiresRecentLogin] when the
  /// learner must sign in again before deleting.
  Future<AuthFailure?> deleteAccount();
}
