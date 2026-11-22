// Project imports:
import 'package:interview_practice/core/error/failure.dart';

enum AuthFailureCode {
  invalidPhoneNumber,
  invalidCode,
  codeExpired,
  tooManyRequests,
  network,

  /// Deleting needs a fresh sign-in (Firebase `requires-recent-login`).
  requiresRecentLogin,

  /// Google is not configured for this build (missing OAuth client / SHA).
  notConfigured,
  unknown,
}

class AuthFailure extends Failure {
  final AuthFailureCode code;

  /// Platform message, for logs only.
  final String? detail;

  AuthFailure(this.code, [this.detail]);

  @override
  List<Object> get props => [code, detail ?? ''];
}
