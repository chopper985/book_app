// Package imports:
import 'package:injectable/injectable.dart';

// Project imports:
import 'package:interview_practice/features/auth/domain/entities/auth_failure.dart';
import 'package:interview_practice/features/auth/domain/entities/auth_results.dart';
import 'package:interview_practice/features/auth/domain/entities/auth_user.dart';
import 'package:interview_practice/features/auth/domain/repositories/auth_repository.dart';
import 'package:interview_practice/features/auth/domain/usecase/normalize_phone_number.dart';
import 'package:interview_practice/features/catalog/domain/repositories/saved_tracks_repository.dart';
import 'package:interview_practice/features/catalog/domain/repositories/user_roadmaps_repository.dart';
import 'package:interview_practice/features/practice/domain/repositories/practice_repository.dart';
import 'package:interview_practice/features/profile/domain/repositories/profile_repository.dart';
import 'package:interview_practice/features/sync/domain/usecase/learner_sync.dart';

@injectable
class WatchAuthUser {
  final AuthRepository _repository;

  WatchAuthUser(this._repository);

  AuthUser? get current => _repository.currentUser;

  Stream<AuthUser?> call() => _repository.userChanges;
}

@injectable
class SignInWithGoogle {
  final AuthRepository _repository;

  SignInWithGoogle(this._repository);

  Future<SignInResult> call() => _repository.signInWithGoogle();
}

@injectable
class RequestPhoneCode {
  final AuthRepository _repository;
  final NormalizePhoneNumber _normalize = const NormalizePhoneNumber();

  RequestPhoneCode(this._repository);

  /// [input] as typed; it is normalized to E.164 first.
  Future<PhoneCodeRequest> call(String input, {int? resendToken}) async {
    final phone = _normalize(input);
    if (phone == null) {
      return PhoneCodeFailed(AuthFailure(AuthFailureCode.invalidPhoneNumber));
    }
    return _repository.requestPhoneCode(phone, resendToken: resendToken);
  }
}

@injectable
class ConfirmPhoneCode {
  final AuthRepository _repository;

  ConfirmPhoneCode(this._repository);

  Future<SignInResult> call(String verificationId, String code) {
    final digits = code.replaceAll(RegExp('[^0-9]'), '');
    if (digits.length != 6) {
      return Future.value(
        SignInFailed(AuthFailure(AuthFailureCode.invalidCode)),
      );
    }
    return _repository.confirmPhoneCode(verificationId, digits);
  }
}

/// Removes the learner's data from this device after leaving an account, so
/// the next person starts fresh (their data stays in the cloud).
@injectable
class ClearLocalLearnerData {
  final PracticeRepository _practice;
  final ProfileRepository _profile;
  final SavedTracksRepository _saved;
  final UserRoadmapsRepository _roadmaps;

  ClearLocalLearnerData(
    this._practice,
    this._profile,
    this._saved,
    this._roadmaps,
  );

  Future<void> call() async {
    await _practice.clearHistory();
    await _saved.replaceAll(const []);
    await _roadmaps.replaceAll(const [], null);
    await _profile.restore(null);
  }
}

/// Uploads pending changes, signs out and clears the device; the app then
/// returns to onboarding with a fresh anonymous account.
@injectable
class SignOut {
  final AuthRepository _repository;
  final LearnerSync _sync;
  final ClearLocalLearnerData _clearLocal;

  SignOut(this._repository, this._sync, this._clearLocal);

  Future<void> call() async {
    await _sync.flush();
    _sync.detach();
    await _repository.signOut();
    await _clearLocal();
  }
}

/// Deletes cloud data, the account, then the device data. Returns a failure
/// (nothing deleted locally) when the learner must sign in again first.
@injectable
class DeleteAccount {
  final AuthRepository _repository;
  final LearnerSync _sync;
  final ClearLocalLearnerData _clearLocal;

  DeleteAccount(this._repository, this._sync, this._clearLocal);

  Future<AuthFailure?> call() async {
    await _sync.flush();
    await _sync.deleteCloudData();
    final failure = await _repository.deleteAccount();
    if (failure != null) {
      // The account still exists: put its data back in the cloud.
      await _sync.syncNow();
      return failure;
    }
    _sync.detach();
    await _clearLocal();
    return null;
  }
}

/// Clears practice history on the device and, when signed in, in the cloud.
@injectable
class ResetProgressEverywhere {
  final PracticeRepository _practice;
  final LearnerSync _sync;

  ResetProgressEverywhere(this._practice, this._sync);

  Future<void> call() async {
    await _sync.clearCloudHistory();
    await _practice.clearHistory();
  }
}
