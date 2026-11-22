// Package imports:
import 'package:flutter_test/flutter_test.dart';

// Project imports:
import 'package:interview_practice/core/utils/dio_api/result.dart';
import 'package:interview_practice/features/content/domain/entities/content_catalog.dart';
import 'package:interview_practice/features/content/domain/entities/localized_text.dart';
import 'package:interview_practice/features/content/domain/entities/quiz_set.dart';
import 'package:interview_practice/features/content/domain/repositories/content_repository.dart';
import 'package:interview_practice/features/practice/domain/repositories/practice_gate.dart';
import 'package:interview_practice/features/premium/data/repositories/usage_repository_impl.dart';
import 'package:interview_practice/features/premium/domain/entities/practice_quota.dart';
import 'package:interview_practice/features/premium/domain/entities/store_models.dart';
import 'package:interview_practice/features/premium/domain/usecase/practice_access.dart';
import 'package:interview_practice/features/premium/domain/usecase/premium_usecases.dart';
import 'package:interview_practice/features/premium/presentation/cubit/paywall_cubit.dart';
import 'package:interview_practice/features/premium/presentation/cubit/quota_cubit.dart';
import 'package:interview_practice/features/sync/domain/entities/learner_snapshot.dart';
import 'package:interview_practice/features/sync/domain/usecase/merge_snapshots.dart';
import '../../helpers/fake_auth_repository.dart';
import '../../helpers/fake_purchase_repository.dart';
import '../../helpers/in_memory_usage_datasource.dart';
import '../../helpers/test_graph.dart';

class _Catalog implements ContentRepository {
  @override
  Future<Result<ContentCatalog>> loadCatalog() async => Result.success(
        ContentCatalog(
          tracks: const [],
          questions: const [],
          sets: [
            QuizSet(
              id: 'free',
              trackId: 'dart',
              title: LocalizedText.neutral('Free'),
              questionIds: const ['q1'],
            ),
            QuizSet(
              id: 'senior',
              trackId: 'dart',
              title: LocalizedText.neutral('Senior'),
              questionIds: const ['q2'],
              accessPlanId: ContentCatalog.premiumPlanId,
            ),
          ],
        ),
      );
}

void main() {
  late FakePurchaseRepository store;
  late InMemoryUsageLocalDataSource usageLocal;
  late UsageRepositoryImpl usage;
  late FixedClock clock;
  late PracticeAccess access;

  setUp(() {
    store = FakePurchaseRepository();
    usageLocal = InMemoryUsageLocalDataSource();
    usage = UsageRepositoryImpl(usageLocal);
    clock = FixedClock(DateTime(2026, 11, 22, 9));
    access = PracticeAccess(store, usage, _Catalog(), clock);
  });

  tearDown(() => access.dispose());

  Future<void> useSessions(int count) async {
    for (var i = 0; i < count; i++) {
      expect(await access.check('free'), isNull);
      await access.consume();
    }
  }

  group('PracticeAccess', () {
    test('free plan: 3 sessions a day, new ones the next day', () async {
      await useSessions(PremiumPlans.freeDailySessions);
      expect(access.quota.remainingToday, 0);
      expect(await access.check('free'), PracticeDenial.quotaExhausted);

      clock.value = DateTime(2026, 11, 23, 1);
      expect(access.quota.remainingToday, PremiumPlans.freeDailySessions);
      expect(await access.check('free'), isNull);
    });

    test('Middle/Senior sets need Premium, extra sessions do not unlock',
        () async {
      store.status = const StoreStatus(purchasedSessions: 10);
      expect(await access.check('senior'), PracticeDenial.premiumLevel);

      store.status = const StoreStatus(isPremium: true);
      expect(await access.check('senior'), isNull);
    });

    test('premium plan is capped at 10 sessions a day', () async {
      store.status = const StoreStatus(isPremium: true);
      await useSessions(PremiumPlans.premiumDailySessions);
      expect(await access.check('senior'), PracticeDenial.quotaExhausted);
    });

    test('extra sessions are used after the daily ones and never refill',
        () async {
      store.status = const StoreStatus(purchasedSessions: 2);
      await useSessions(PremiumPlans.freeDailySessions);
      expect(usage.extraSessionsUsed, 0, reason: 'daily allowance first');
      expect(access.quota.extraSessions, 2);

      await useSessions(2);
      expect(usage.extraSessionsUsed, 2);
      expect(access.quota.extraSessions, 0);
      expect(await access.check('free'), PracticeDenial.quotaExhausted);

      clock.value = DateTime(2026, 11, 23, 9);
      expect(access.quota.extraSessions, 0);
    });

    test('quota stream follows purchases and usage', () async {
      final quotas = <PracticeQuota>[];
      final subscription = access.changes.listen(quotas.add);
      await access.consume();
      store.status = const StoreStatus(isPremium: true);
      await Future<void>.delayed(Duration.zero);
      expect(quotas.map((q) => q.usedToday), [1, 1]);
      expect(quotas.last.isPremium, isTrue);
      expect(quotas.last.remainingToday, PremiumPlans.premiumDailySessions - 1);
      await subscription.cancel();
    });

    test('usage keeps only the last days', () async {
      for (var day = 1; day <= 10; day++) {
        await usage.recordDailyUse(DateTime(2026, 11, day));
      }
      expect(usageLocal.days.length, UsageRepositoryImpl.keptDays);
      expect(usage.usedOn(DateTime(2026, 11, 10, 23)), 1);
      expect(usage.usedOn(DateTime(2026, 11, 3)), 0);
    });
  });

  test('sync keeps the higher extra-session count', () {
    const merge = MergeSnapshots();
    expect(
      merge(
        const LearnerSnapshot(extraSessionsUsed: 2),
        const LearnerSnapshot(extraSessionsUsed: 5),
      ).extraSessionsUsed,
      5,
    );
    expect(
      merge(const LearnerSnapshot(extraSessionsUsed: 4), null)
          .extraSessionsUsed,
      4,
    );
  });

  group('PaywallCubit', () {
    PaywallCubit newCubit() => PaywallCubit(
          store,
          LoadStorePackages(store),
          PurchasePackage(store),
          RestorePurchases(store),
        );

    test('preselects the yearly plan, buying it activates Premium', () async {
      final cubit = newCubit();
      await cubit.load();
      expect(cubit.state.packages.map((p) => p.kind), [
        StorePackageKind.monthly,
        StorePackageKind.annual,
        StorePackageKind.sessions,
      ]);
      expect(cubit.state.selectedId, annualPackage.id);

      await cubit.purchase();
      expect(cubit.state.notice, PaywallNotice.purchased);
      expect(access.quota.isPremium, isTrue);
      await cubit.close();
    });

    test('premium learners only see extra-session packs', () async {
      store.status = const StoreStatus(isPremium: true);
      final cubit = newCubit();
      await cubit.load();
      expect(cubit.state.packages, [sessionsPackage]);

      await cubit.purchase();
      expect(cubit.state.notice, PaywallNotice.sessionsAdded);
      expect(cubit.state.addedSessions, 10);
      expect(access.quota.extraSessions, 10);
      await cubit.close();
    });

    test('not configured, cancelled and failed purchases', () async {
      store.isConfigured = false;
      var cubit = newCubit();
      await cubit.load();
      expect(cubit.state.configured, isFalse);
      expect(cubit.state.loading, isFalse);
      await cubit.close();

      store.isConfigured = true;
      cubit = newCubit();
      await cubit.load();
      store.nextOutcome = const PurchaseCancelled();
      await cubit.purchase();
      expect(cubit.state.busy, isFalse);
      expect(cubit.state.notice, isNull);
      expect(cubit.state.failure, isNull);

      store.nextOutcome =
          PurchaseFailed(PurchaseFailure(PurchaseFailureCode.network));
      await cubit.purchase();
      expect(cubit.state.failure?.code, PurchaseFailureCode.network);

      store.nextOutcome = null;
      await cubit.restore();
      expect(cubit.state.notice, PaywallNotice.nothingToRestore);
      await cubit.close();
    });
  });

  test('QuotaCubit follows usage', () async {
    final cubit = QuotaCubit(access);
    await access.consume();
    await Future<void>.delayed(Duration.zero);
    expect(cubit.state.usedToday, 1);
    await cubit.close();
  });

  test('purchases follow the Firebase account', () async {
    final auth = FakeAuthRepository();
    final identity = PurchaseIdentity(auth, store)..start();
    auth.emitUser(googleUser);
    await Future<void>.delayed(Duration.zero);
    expect(store.identified, [anonymousUser.uid, googleUser.uid]);
    await identity.dispose();
  });
}
