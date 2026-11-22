// Dart imports:
import 'dart:async';

// Project imports:
import 'package:interview_practice/features/auth/domain/entities/auth_failure.dart';
import 'package:interview_practice/features/auth/domain/entities/auth_results.dart';
import 'package:interview_practice/features/auth/domain/entities/auth_user.dart';
import 'package:interview_practice/features/auth/domain/repositories/auth_repository.dart';

const AuthUser anonymousUser = AuthUser(uid: 'anon-1', isAnonymous: true);

const AuthUser googleUser = AuthUser(
  uid: 'user-1',
  isAnonymous: false,
  email: 'lan@example.com',
  providers: {AuthProviderKind.google},
);

const AuthUser facebookUser = AuthUser(
  uid: 'user-3',
  isAnonymous: false,
  displayName: 'Lan Nguyen',
  email: 'lan.fb@example.com',
  providers: {AuthProviderKind.facebook},
);

/// Scriptable [AuthRepository]: tests set the next results and push users.
class FakeAuthRepository implements AuthRepository {
  final StreamController<AuthUser?> _users =
      StreamController<AuthUser?>.broadcast();
  AuthUser? _user;

  SignInResult googleResult = const SignInSuccess(googleUser);
  SignInResult facebookResult = const SignInSuccess(facebookUser);
  PhoneCodeRequest codeRequest = const PhoneCodeSent('verification-1');
  SignInResult confirmResult = const SignInSuccess(
    AuthUser(
      uid: 'user-2',
      isAnonymous: false,
      phoneNumber: '+84912345678',
      providers: {AuthProviderKind.phone},
    ),
  );
  AuthFailure? deleteFailure;
  final List<String> calls = [];

  FakeAuthRepository([this._user = anonymousUser]);

  void emitUser(AuthUser? user) {
    _user = user;
    _users.add(user);
  }

  @override
  AuthUser? get currentUser => _user;

  @override
  Stream<AuthUser?> get userChanges => _users.stream;

  @override
  Future<void> ensureSignedIn() async {
    calls.add('ensureSignedIn');
    if (_user == null) emitUser(anonymousUser);
  }

  @override
  Future<SignInResult> signInWithGoogle() async {
    calls.add('google');
    if (googleResult case SignInSuccess(:final user)) emitUser(user);
    return googleResult;
  }

  @override
  Future<SignInResult> signInWithFacebook() async {
    calls.add('facebook');
    if (facebookResult case SignInSuccess(:final user)) emitUser(user);
    return facebookResult;
  }

  @override
  Future<PhoneCodeRequest> requestPhoneCode(
    String phoneNumber, {
    int? resendToken,
  }) async {
    calls.add('code $phoneNumber ${resendToken ?? ''}'.trim());
    return codeRequest;
  }

  @override
  Future<SignInResult> confirmPhoneCode(
    String verificationId,
    String code,
  ) async {
    calls.add('confirm $verificationId $code');
    if (confirmResult case SignInSuccess(:final user)) emitUser(user);
    return confirmResult;
  }

  @override
  Future<void> signOut() async {
    calls.add('signOut');
    emitUser(anonymousUser);
  }

  @override
  Future<AuthFailure?> deleteAccount() async {
    calls.add('delete');
    if (deleteFailure == null) emitUser(anonymousUser);
    return deleteFailure;
  }
}
