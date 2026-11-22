// Project imports:
import 'package:interview_practice/core/app/languages/data/localization.dart';
import 'package:interview_practice/features/auth/domain/entities/auth_failure.dart';

extension AuthFailureMessage on AuthFailure {
  String get message => switch (code) {
        AuthFailureCode.invalidPhoneNumber => Strings.authErrorInvalidPhone,
        AuthFailureCode.invalidCode => Strings.authErrorInvalidCode,
        AuthFailureCode.codeExpired => Strings.authErrorCodeExpired,
        AuthFailureCode.tooManyRequests => Strings.authErrorTooMany,
        AuthFailureCode.network => Strings.authErrorNetwork,
        AuthFailureCode.requiresRecentLogin => Strings.authErrorRecentLogin,
        AuthFailureCode.notConfigured => Strings.authErrorNotConfigured,
        AuthFailureCode.unknown => Strings.authErrorUnknown,
      }
          .i18n;
}
