/// Counts practice sessions on this device.
abstract class UsageRepository {
  /// Sessions started on the local calendar day of [day].
  int usedOn(DateTime day);

  /// Extra sessions used so far (synced, so reinstalling does not refill).
  int get extraSessionsUsed;

  Stream<void> get changes;

  Future<void> recordDailyUse(DateTime day);

  Future<void> recordExtraUse();

  /// Replaces the extra sessions used (cloud merge, sign-out).
  Future<void> restoreExtraSessionsUsed(int value);
}
