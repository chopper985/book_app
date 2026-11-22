// Package imports:
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

// Project imports:
import 'package:interview_practice/features/premium/domain/entities/store_models.dart';
import 'package:interview_practice/features/premium/domain/repositories/purchase_repository.dart';
import 'package:interview_practice/features/premium/domain/usecase/premium_usecases.dart';

part 'paywall_state.dart';

/// Loads the store packages and buys or restores them.
@injectable
class PaywallCubit extends Cubit<PaywallState> {
  final PurchaseRepository _store;
  final LoadStorePackages _loadPackages;
  final PurchasePackage _purchasePackage;
  final RestorePurchases _restorePurchases;

  PaywallCubit(
    this._store,
    this._loadPackages,
    this._purchasePackage,
    this._restorePurchases,
  ) : super(const PaywallState());

  Future<void> load() async {
    if (!_store.isConfigured) {
      emit(state.copyWith(loading: false, configured: false));
      return;
    }
    emit(state.copyWith(loading: true));
    final packages = await _loadPackages();
    if (isClosed) return;
    final premium = _store.status.isPremium;
    final visible = [
      for (final package in packages)
        // Premium learners can still buy extra sessions.
        if (!premium || package.kind == StorePackageKind.sessions) package,
    ]..sort((a, b) => a.kind.index.compareTo(b.kind.index));
    final preferred = visible.where((p) => p.kind == StorePackageKind.annual);
    emit(
      state.copyWith(
        loading: false,
        configured: visible.isNotEmpty,
        packages: visible,
        selectedId: () => preferred.isNotEmpty
            ? preferred.first.id
            : (visible.isEmpty ? null : visible.first.id),
      ),
    );
  }

  void select(String packageId) => emit(
        state.copyWith(selectedId: () => packageId, failure: () => null),
      );

  Future<void> purchase() async {
    final package = state.selected;
    if (package == null || state.busy) return;
    emit(state.copyWith(busy: true, failure: () => null, notice: () => null));
    final outcome = await _purchasePackage(package);
    if (isClosed) return;
    switch (outcome) {
      case PurchaseCompleted():
        final pack = package.kind == StorePackageKind.sessions;
        emit(
          state.copyWith(
            busy: false,
            notice: () =>
                pack ? PaywallNotice.sessionsAdded : PaywallNotice.purchased,
            addedSessions: pack ? package.sessions : 0,
          ),
        );
      case PurchaseCancelled():
        emit(state.copyWith(busy: false));
      case PurchaseFailed(:final failure):
        emit(state.copyWith(busy: false, failure: () => failure));
    }
  }

  Future<void> restore() async {
    if (state.busy) return;
    emit(state.copyWith(busy: true, failure: () => null, notice: () => null));
    final outcome = await _restorePurchases();
    if (isClosed) return;
    switch (outcome) {
      case PurchaseCompleted(:final status):
        emit(
          state.copyWith(
            busy: false,
            notice: () => status.isPremium || status.purchasedSessions > 0
                ? PaywallNotice.restored
                : PaywallNotice.nothingToRestore,
          ),
        );
      case PurchaseCancelled():
        emit(state.copyWith(busy: false));
      case PurchaseFailed(:final failure):
        emit(state.copyWith(busy: false, failure: () => failure));
    }
  }
}
