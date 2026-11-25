// Package imports:
import 'package:flutter_test/flutter_test.dart';
import 'package:i18n_extension/i18n_extension.dart' show I18n;
import 'package:material_ui/material_ui.dart';
import 'package:sizer/sizer.dart';

// Project imports:
import 'package:interview_practice/core/app/languages/data/localization.dart';
import 'package:interview_practice/features/catalog/domain/usecase/get_role_technologies.dart';
import 'package:interview_practice/features/catalog/presentation/widgets/compact_roadmap_strip.dart';
import 'package:interview_practice/features/catalog/presentation/widgets/role_technologies_section.dart';
import '../../helpers/test_graph.dart';
import 'position_roadmap_test.dart' show positionData;

void main() {
  testWidgets('role list and compact roadmaps fit 320 px at 1.3x text',
      (tester) async {
    final graph = await TestGraph.create(data: positionData());
    final roles =
        (await tester.runAsync(GetRoleTechnologies(graph.catalog).call))!;
    final added = <String>[];
    final tried = <String>[];

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
            home: Scaffold(
              body: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  CompactRoadmapStrip(
                    tracks: roles.single.main,
                    completion: const {'dart': 0.4},
                    onOpen: (_) {},
                  ),
                  RoleTechnologiesSection(
                    roles: roles,
                    selected: roles.single,
                    onSelectRole: (_) {},
                    addedTrackIds: const {'sql'},
                    onAdd: (t) => added.add(t.track.id),
                    onTry: (t) => tried.add(t.track.id),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pump();
    expect(tester.takeException(), isNull);

    expect(
      find.text(Strings.exploreRoleAdded.i18n),
      findsOneWidget,
      reason: 'sql is already a roadmap',
    );
    await tester.tap(find.text(Strings.exploreRoleAdd.i18n));
    await tester.tap(find.text(Strings.exploreRoleTry.i18n).first);
    expect(added, ['dart']);
    expect(tried, ['dart']);
  });
}
