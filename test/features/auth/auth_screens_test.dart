// Flutter imports:
import 'package:material_ui/material_ui.dart';

// Package imports:
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:i18n_extension/i18n_extension.dart' show I18n;
import 'package:sizer/sizer.dart';

// Project imports:
import 'package:interview_practice/core/app/languages/data/localization.dart';
import 'package:interview_practice/features/auth/domain/entities/auth_results.dart';
import 'package:interview_practice/features/auth/domain/usecase/account_usecases.dart';
import 'package:interview_practice/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:interview_practice/features/auth/presentation/cubit/sign_in_cubit.dart';
import 'package:interview_practice/features/auth/presentation/screens/phone_sign_in_screen.dart';
import 'package:interview_practice/features/auth/presentation/screens/sign_in_screen.dart';
import 'package:interview_practice/features/profile/presentation/widgets/account_section.dart';
import '../../helpers/fake_auth_repository.dart';
import '../../helpers/test_graph.dart';

void main() {
  Future<void> pumpSmall(WidgetTester tester, Widget child) async {
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
            home: child,
          ),
        ),
      ),
    );
    await tester.pump();
  }

  SignInCubit signInCubit(FakeAuthRepository auth) => SignInCubit(
        SignInWithGoogle(auth),
        SignInWithFacebook(auth),
        RequestPhoneCode(auth),
        ConfirmPhoneCode(auth),
      );

  testWidgets('sign-in screen offers Google, Facebook, phone and guest',
      (tester) async {
    final auth = FakeAuthRepository();
    await pumpSmall(
      tester,
      BlocProvider(
        create: (_) => signInCubit(auth),
        child: const SignInScreen(),
      ),
    );
    expect(tester.takeException(), isNull);
    expect(find.text(Strings.authGoogle.i18n), findsOneWidget);
    expect(find.text(Strings.authFacebook.i18n), findsOneWidget);
    expect(find.text(Strings.authPhone.i18n), findsOneWidget);
    expect(find.text(Strings.authGuest.i18n), findsOneWidget);

    // Cancelled, so the screen stays (no router to pop in this test).
    auth.facebookResult = const SignInCancelled();
    await tester.tap(find.text(Strings.authFacebook.i18n));
    await tester.pump();
    expect(auth.calls, contains('facebook'));
  });

  testWidgets('phone screen moves from number to code', (tester) async {
    final auth = FakeAuthRepository();
    final cubit = signInCubit(auth);
    await pumpSmall(
      tester,
      BlocProvider.value(value: cubit, child: const PhoneSignInScreen()),
    );
    expect(tester.takeException(), isNull);
    expect(find.text(Strings.authPhoneTitle.i18n), findsOneWidget);

    await tester.enterText(find.byType(TextField), '0912345678');
    await tester.pump();
    await tester.tap(find.text(Strings.authSendCode.i18n));
    await tester.pump();

    expect(find.text(Strings.authCodeTitle.i18n), findsOneWidget);
    expect(
      find.text(Strings.authResendIn.i18n.fill([60])),
      findsOneWidget,
      reason: 'resend countdown',
    );
    expect(tester.takeException(), isNull);

    await tester.pumpWidget(const SizedBox());
    await tester.runAsync(cubit.close);
  });

  group('account section', () {
    late TestGraph graph;

    setUp(() async => graph = await TestGraph.create());

    AuthCubit authCubit() {
      final clear = ClearLocalLearnerData(
        graph.practice,
        graph.profiles,
        graph.saved,
        graph.roadmaps,
        graph.usage,
      );
      return AuthCubit(
        WatchAuthUser(graph.auth),
        SignOut(graph.auth, graph.sync, clear),
        DeleteAccount(graph.auth, graph.sync, clear),
      );
    }

    Widget section(AuthCubit cubit) => Scaffold(
          body: BlocProvider.value(
            value: cubit,
            child: const SingleChildScrollView(child: AccountSection()),
          ),
        );

    testWidgets('guest sees the sign-in call to action', (tester) async {
      final cubit = authCubit();
      await pumpSmall(tester, section(cubit));
      expect(find.text(Strings.accountGuest.i18n), findsOneWidget);
      expect(find.text(Strings.accountSignIn.i18n), findsOneWidget);
      await tester.pumpWidget(const SizedBox());
      await tester.runAsync(cubit.close);
    });

    testWidgets('linked account shows identity, sign-out and delete',
        (tester) async {
      graph.auth.emitUser(googleUser);
      final cubit = authCubit();
      await pumpSmall(tester, section(cubit));
      expect(
        find.text(Strings.accountSignedInWith.i18n.fill(['lan@example.com'])),
        findsOneWidget,
      );
      expect(find.text(Strings.accountSignOut.i18n), findsOneWidget);
      expect(find.text(Strings.accountDelete.i18n), findsOneWidget);

      await tester.tap(find.text(Strings.accountSignOut.i18n));
      await tester.pumpAndSettle();
      expect(find.text(Strings.accountSignOutTitle.i18n), findsOneWidget);
      await tester.tap(find.text(Strings.accountCancel.i18n));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox());
      await tester.runAsync(cubit.close);
    });
  });
}
