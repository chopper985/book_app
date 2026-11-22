// Dart imports:
import 'dart:async';

// Flutter imports:
import 'package:flutter/foundation.dart';

// Package imports:
import 'package:firebase_auth/firebase_auth.dart' hide PhoneCodeSent;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:injectable/injectable.dart';

// Project imports:
import 'package:interview_practice/core/analytics/app_firebase.dart';
import 'package:interview_practice/features/auth/domain/entities/auth_failure.dart';
import 'package:interview_practice/features/auth/domain/entities/auth_results.dart';
import 'package:interview_practice/features/auth/domain/entities/auth_user.dart';
import 'package:interview_practice/features/auth/domain/repositories/auth_repository.dart';

/// Firebase Auth with Google and phone (SMS) sign-in. New credentials are
/// linked to the current anonymous account so its local data keeps its uid;
/// a credential that already belongs to another account signs in to it.
@LazySingleton(as: AuthRepository)
class AuthRepositoryImpl implements AuthRepository {
  bool _googleReady = false;

  FirebaseAuth? get _auth => AppFirebase.isReady ? FirebaseAuth.instance : null;

  @override
  AuthUser? get currentUser => _map(_auth?.currentUser);

  @override
  Stream<AuthUser?> get userChanges =>
      _auth?.userChanges().map(_map) ?? Stream.value(null);

  @override
  Future<void> ensureSignedIn() async {
    final auth = _auth;
    if (auth == null || auth.currentUser != null) return;
    try {
      await auth.signInAnonymously();
    } on FirebaseAuthException catch (error) {
      // Anonymous provider disabled or offline: the app keeps working locally.
      debugPrint('Anonymous sign-in failed: ${error.code}');
    }
  }

  @override
  Future<SignInResult> signInWithGoogle() async {
    if (_auth == null) {
      return SignInFailed(AuthFailure(AuthFailureCode.notConfigured));
    }
    try {
      final google = GoogleSignIn.instance;
      if (!_googleReady) {
        // Android reads the web client id generated from google-services.json.
        await google.initialize();
        _googleReady = true;
      }
      final account = await google.authenticate();
      final idToken = account.authentication.idToken;
      if (idToken == null) {
        return SignInFailed(AuthFailure(AuthFailureCode.notConfigured));
      }
      return await _linkOrSignIn(
        GoogleAuthProvider.credential(idToken: idToken),
      );
    } on GoogleSignInException catch (error) {
      if (error.code == GoogleSignInExceptionCode.canceled) {
        return const SignInCancelled();
      }
      return SignInFailed(
        AuthFailure(
          error.code == GoogleSignInExceptionCode.clientConfigurationError ||
                  error.code ==
                      GoogleSignInExceptionCode.providerConfigurationError
              ? AuthFailureCode.notConfigured
              : AuthFailureCode.unknown,
          error.description,
        ),
      );
    }
  }

  @override
  Future<PhoneCodeRequest> requestPhoneCode(
    String phoneNumber, {
    int? resendToken,
  }) async {
    final auth = _auth;
    if (auth == null) {
      return PhoneCodeFailed(AuthFailure(AuthFailureCode.notConfigured));
    }
    final completer = Completer<PhoneCodeRequest>();
    void complete(PhoneCodeRequest value) {
      if (!completer.isCompleted) completer.complete(value);
    }

    await auth.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      forceResendingToken: resendToken,
      timeout: const Duration(seconds: 60),
      verificationCompleted: (credential) async {
        // Android auto-retrieval: sign in without typing the code.
        final result = await _linkOrSignIn(credential);
        complete(
          result is SignInSuccess
              ? PhoneAutoVerified(result)
              : PhoneCodeFailed(
                  (result as SignInFailed?)?.failure ??
                      AuthFailure(AuthFailureCode.unknown),
                ),
        );
      },
      verificationFailed: (error) =>
          complete(PhoneCodeFailed(_failureOf(error))),
      codeSent: (verificationId, token) =>
          complete(PhoneCodeSent(verificationId, resendToken: token)),
      codeAutoRetrievalTimeout: (_) {},
    );
    return completer.future;
  }

  @override
  Future<SignInResult> confirmPhoneCode(
    String verificationId,
    String code,
  ) {
    return _linkOrSignIn(
      PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: code,
      ),
    );
  }

  @override
  Future<void> signOut() async {
    final auth = _auth;
    if (auth == null) return;
    if (_googleReady) {
      try {
        await GoogleSignIn.instance.signOut();
      } catch (error) {
        debugPrint('Google sign-out failed: $error');
      }
    }
    await auth.signOut();
    await ensureSignedIn();
  }

  @override
  Future<AuthFailure?> deleteAccount() async {
    final user = _auth?.currentUser;
    if (user == null) return null;
    try {
      await user.delete();
      if (_googleReady) await GoogleSignIn.instance.disconnect();
      await ensureSignedIn();
      return null;
    } on FirebaseAuthException catch (error) {
      return _failureOf(error);
    }
  }

  /// Links [credential] to the current user, or signs in when there is no
  /// user or the credential already belongs to another account.
  Future<SignInResult> _linkOrSignIn(AuthCredential credential) async {
    final auth = _auth!;
    final current = auth.currentUser;
    try {
      if (current == null) {
        final result = await auth.signInWithCredential(credential);
        return SignInSuccess(_map(result.user)!);
      }
      final result = await current.linkWithCredential(credential);
      return SignInSuccess(_map(result.user)!);
    } on FirebaseAuthException catch (error) {
      if (error.code == 'credential-already-in-use' ||
          error.code == 'email-already-in-use' ||
          error.code == 'provider-already-linked') {
        try {
          final result = await auth.signInWithCredential(
            error.credential ?? credential,
          );
          return SignInSuccess(
            _map(result.user)!,
            switchedAccount: result.user?.uid != current?.uid,
          );
        } on FirebaseAuthException catch (inner) {
          return SignInFailed(_failureOf(inner));
        }
      }
      return SignInFailed(_failureOf(error));
    }
  }

  static AuthFailure _failureOf(FirebaseAuthException error) {
    final code = switch (error.code) {
      'invalid-phone-number' || 'missing-phone-number' =>
        AuthFailureCode.invalidPhoneNumber,
      'invalid-verification-code' => AuthFailureCode.invalidCode,
      'session-expired' || 'code-expired' => AuthFailureCode.codeExpired,
      'too-many-requests' || 'quota-exceeded' =>
        AuthFailureCode.tooManyRequests,
      'network-request-failed' => AuthFailureCode.network,
      'requires-recent-login' => AuthFailureCode.requiresRecentLogin,
      'operation-not-allowed' ||
      'app-not-authorized' ||
      'invalid-app-credential' ||
      'missing-client-identifier' =>
        AuthFailureCode.notConfigured,
      _ => AuthFailureCode.unknown,
    };
    return AuthFailure(code, error.message);
  }

  static AuthUser? _map(User? user) {
    if (user == null) return null;
    return AuthUser(
      uid: user.uid,
      isAnonymous: user.isAnonymous,
      displayName: user.displayName,
      email: user.email,
      phoneNumber: user.phoneNumber,
      photoUrl: user.photoURL,
      providers: {
        for (final info in user.providerData)
          if (info.providerId == GoogleAuthProvider.PROVIDER_ID)
            AuthProviderKind.google
          else if (info.providerId == PhoneAuthProvider.PROVIDER_ID)
            AuthProviderKind.phone,
      },
    );
  }
}
