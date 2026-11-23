// Package imports:
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:sizer/sizer.dart';

// Project imports:
import 'package:interview_practice/features/catalog/presentation/widgets/track_logo.dart';

void main() {
  Future<void> pumpLogo(WidgetTester tester, Widget logo) => tester.pumpWidget(
        Sizer(
          builder: (context, orientation, deviceType) => MaterialApp(
            home: Scaffold(body: Center(child: logo)),
          ),
        ),
      );

  testWidgets('tracks with a Figma icon draw the SVG', (tester) async {
    await pumpLogo(tester, const TrackLogo(trackId: 'go'));
    expect(find.byType(SvgPicture), findsOneWidget);
  });

  testWidgets('other tracks draw their brand monogram', (tester) async {
    for (final (id, text) in [
      ('javascript', 'JS'),
      ('react_native', 'RN'),
      ('nodejs', 'node'),
      ('java', 'Java'),
      ('swift', 'Swift'),
      ('kotlin', 'K'),
      ('typescript', 'TS'),
      ('elixir', 'el'),
    ]) {
      await pumpLogo(tester, TrackLogo(trackId: id));
      expect(find.text(text), findsOneWidget, reason: id);
      expect(find.byType(SvgPicture), findsNothing);
    }
    expect(tester.takeException(), isNull);
  });

  testWidgets('meta icon falls back to a generic code icon', (tester) async {
    await pumpLogo(tester, const TrackLogo(trackId: 'java', meta: true));
    expect(find.byIcon(Icons.code), findsOneWidget);
  });
}
