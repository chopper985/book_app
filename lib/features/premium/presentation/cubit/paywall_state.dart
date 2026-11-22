part of 'paywall_cubit.dart';

/// Shown once after a purchase or restore.
enum PaywallNotice { purchased, sessionsAdded, restored, nothingToRestore }

class PaywallState extends Equatable {
  final bool loading;
  final bool configured;
  final List<StorePackage> packages;
  final String? selectedId;
  final bool busy;
  final PurchaseFailure? failure;
  final PaywallNotice? notice;

  /// Sessions added by the last pack purchase, for [PaywallNotice.sessionsAdded].
  final int addedSessions;

  const PaywallState({
    this.loading = true,
    this.configured = true,
    this.packages = const [],
    this.selectedId,
    this.busy = false,
    this.failure,
    this.notice,
    this.addedSessions = 0,
  });

  StorePackage? get selected {
    for (final package in packages) {
      if (package.id == selectedId) return package;
    }
    return null;
  }

  PaywallState copyWith({
    bool? loading,
    bool? configured,
    List<StorePackage>? packages,
    String? Function()? selectedId,
    bool? busy,
    PurchaseFailure? Function()? failure,
    PaywallNotice? Function()? notice,
    int? addedSessions,
  }) {
    return PaywallState(
      loading: loading ?? this.loading,
      configured: configured ?? this.configured,
      packages: packages ?? this.packages,
      selectedId: selectedId == null ? this.selectedId : selectedId(),
      busy: busy ?? this.busy,
      failure: failure == null ? this.failure : failure(),
      notice: notice == null ? this.notice : notice(),
      addedSessions: addedSessions ?? this.addedSessions,
    );
  }

  @override
  List<Object?> get props => [
        loading,
        configured,
        packages,
        selectedId,
        busy,
        failure,
        notice,
        addedSessions,
      ];
}
