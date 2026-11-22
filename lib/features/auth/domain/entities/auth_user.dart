// Package imports:
import 'package:equatable/equatable.dart';

enum AuthProviderKind { google, facebook, phone }

/// The signed-in Firebase account. Every install has one: an anonymous
/// account until the learner links Google, Facebook or a phone number.
class AuthUser extends Equatable {
  final String uid;
  final bool isAnonymous;
  final String? displayName;
  final String? email;
  final String? phoneNumber;
  final String? photoUrl;
  final Set<AuthProviderKind> providers;

  const AuthUser({
    required this.uid,
    required this.isAnonymous,
    this.displayName,
    this.email,
    this.phoneNumber,
    this.photoUrl,
    this.providers = const {},
  });

  /// Linked to Google, Facebook or a phone number, so data can follow the learner.
  bool get isLinked => !isAnonymous && providers.isNotEmpty;

  /// Email or phone, whichever identifies the account.
  String? get identifier => email ?? phoneNumber;

  @override
  List<Object?> get props =>
      [uid, isAnonymous, displayName, email, phoneNumber, photoUrl, providers];
}
