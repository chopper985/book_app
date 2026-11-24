// Dart imports:
import 'dart:async';

/// Signing in to an existing account while the device holds guest
/// progress: the learner decides whether that progress joins the account.
class GuestDataPrompt {
  /// Practice sessions done as a guest on this device.
  final int sessions;
  final Completer<bool> _keep = Completer<bool>();

  GuestDataPrompt(this.sessions);

  bool get isResolved => _keep.isCompleted;

  /// `true` merges the guest progress into the account, `false` keeps only
  /// the account's data.
  Future<bool> get keepGuestProgress => _keep.future;

  void resolve({required bool keepGuestProgress}) {
    if (!_keep.isCompleted) _keep.complete(keepGuestProgress);
  }
}
