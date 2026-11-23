// Flutter imports:
import 'package:material_ui/material_ui.dart';

// Package imports:
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:i18n_extension/i18n_extension.dart' show I18n;
import 'package:sizer/sizer.dart';

// Project imports:
import 'package:interview_practice/core/app/languages/data/localization.dart';
import 'package:interview_practice/features/auth/domain/usecase/account_usecases.dart';
import 'package:interview_practice/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:interview_practice/features/premium/domain/usecase/practice_access.dart';
import 'package:interview_practice/features/premium/domain/usecase/premium_usecases.dart';
import 'package:interview_practice/features/premium/presentation/cubit/paywall_cubit.dart';
import 'package:interview_practice/features/premium/presentation/cubit/quota_cubit.dart';
import 'package:interview_practice/features/premium/presentation/screens/paywall_screen.dart';
import '../../helpers/fake_purchase_repository.dart';
import '../../helpers/test_graph.dart';

void main() {
  testWidgets('paywall lists the plans on a small screen at 1.3x text',
      (tester) async {
    final graph = await TestGraph.create();
    final store = FakePurchaseRepository();
    final paywall = PaywallCubit(
      store,
      LoadStorePackages(store),
      PurchasePackage(store),
      RestorePurchases(store),
    );
    final quota = QuotaCubit(
      PracticeAccess(store, graph.usage, graph.content, graph.clock),
    );
    final clear = ClearLocalLearnerData(
      graph.practice,
      graph.profiles,
      graph.saved,
      graph.roadmaps,
      graph.usage,
    );
    final auth = AuthCubit(
      WatchAuthUser(graph.auth),
      SignOut(graph.auth, graph.sync, clear),
      DeleteAccount(graph.auth, graph.sync, clear),
    );
    await tester.runAsync(paywall.load);

    await tester.binding.setSurfaceSize(const Size(320, 640));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      I18n(
        initialLocale: const Locale('vi', 'VN'),
        child: Sizer(
          builder: (context, orientation, deviceType) => MaterialApp(
            builder: (context, child) => MediaQuery(
              data: MediaQuery.of(context).copyWith(
                textScaler: const TextScaler.linear(1.3),
              ),
              child: child!,
            ),
            home: MultiBlocProvider(
              providers: [
                BlocProvider.value(value: paywall),
                BlocProvider.value(value: quota),
                BlocProvider.value(value: auth),
              ],
              child: const PaywallScreen(),
            ),
          ),
        ),
      ),
    );
    await tester.pump();

    expect(tester.takeException(), isNull);
    expect(find.text(Strings.premiumTitle.i18n), findsOneWidget);
    // The packages sit below the benefits on a small screen.
    for (final label in [
      Strings.premiumMonthly.i18n,
      Strings.premiumAnnualBadge.i18n,
      Strings.premiumSessionsPack.i18n.fill([10]),
    ]) {
      await tester.scrollUntilVisible(find.text(label), 100);
      expect(find.text(label), findsOneWidget);
    }
    expect(find.text(Strings.premiumContinue.i18n), findsOneWidget);
    expect(tester.takeException(), isNull);

    await tester.pumpWidget(const SizedBox());
    await tester.runAsync(() async {
      await paywall.close();
      await quota.close();
      await auth.close();
    });
  });
}
