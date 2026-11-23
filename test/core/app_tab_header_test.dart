// Flutter imports:
import 'package:material_ui/material_ui.dart';

// Package imports:
import 'package:flutter_test/flutter_test.dart';
import 'package:sizer/sizer.dart';

// Project imports:
import 'package:interview_practice/core/utils/widgets/app_tab_header.dart';

void main() {
  Future<void> pump(WidgetTester tester, Widget header) async {
    await tester.binding.setSurfaceSize(const Size(320, 640));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      Sizer(
        builder: (context, orientation, deviceType) => MaterialApp(
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(context).copyWith(
              textScaler: const TextScaler.linear(1.3),
            ),
            child: child!,
          ),
          home: Scaffold(body: header),
        ),
      ),
    );
  }

  testWidgets('shows title, subtitle, initial and opens the profile',
      (tester) async {
    var taps = 0;
    await pump(
      tester,
      AppTabHeader(
        title: 'Lộ trình',
        subtitle: 'Back-end Developer · Java / Spring Boot · Fresher / Junior',
        streakDays: 5,
        displayName: 'lan',
        onAvatarTap: () => taps++,
      ),
    );
    expect(tester.takeException(), isNull, reason: 'long subtitle ellipsized');
    expect(find.text('Lộ trình'), findsOneWidget);
    expect(find.text('L'), findsOneWidget, reason: 'avatar initial');

    await tester.tap(find.text('L'));
    expect(taps, 1);
  });

  testWidgets('no subtitle and no tap target on the profile tab',
      (tester) async {
    await pump(
      tester,
      const AppTabHeader(
        title: 'Cá nhân',
        subtitle: '',
        streakDays: 0,
        displayName: '',
      ),
    );
    expect(find.text('?'), findsOneWidget, reason: 'no name yet');
    expect(find.byType(Text), findsNWidgets(3), reason: 'title, streak, ?');
  });
}
