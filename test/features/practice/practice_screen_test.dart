// Package imports:
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:i18n_extension/i18n_extension.dart';
import 'package:material_ui/material_ui.dart';
import 'package:sizer/sizer.dart';

// Project imports:
import 'package:interview_practice/core/app/languages/data/localization.dart';
import 'package:interview_practice/core/helpers/app_clock.dart';
import 'package:interview_practice/core/utils/dio_api/result.dart';
import 'package:interview_practice/features/content/data/parsers/content_parser.dart';
import 'package:interview_practice/features/content/domain/entities/content_catalog.dart';
import 'package:interview_practice/features/content/domain/repositories/content_repository.dart';
import 'package:interview_practice/features/practice/data/repositories/practice_repository_impl.dart';
import 'package:interview_practice/features/practice/domain/usecase/practice_usecases.dart';
import 'package:interview_practice/features/practice/presentation/cubit/practice_cubit.dart';
import 'package:interview_practice/features/practice/presentation/screens/practice_screen.dart';
import 'package:interview_practice/features/practice/presentation/widgets/practice_option_tile.dart';
import '../../helpers/in_memory_practice_datasource.dart';
import '../../helpers/open_practice_gate.dart';
import '../content/content_test_data.dart';

class _FakeContentRepository implements ContentRepository {
  final ContentCatalog catalog;

  _FakeContentRepository(this.catalog);

  @override
  Future<Result<ContentCatalog>> loadCatalog() async => Result.success(catalog);
}

const _longLine = '  print("this is a very long line of code that must scroll '
    'horizontally instead of wrapping or overflowing the screen width");';

void main() {
  late PracticeCubit cubit;

  Future<void> start(WidgetTester tester) async {
    final code = choiceQuestion()
      ..['type'] = 'outputPrediction'
      ..['code'] = {
        'language': 'dart',
        'source': '@override\nvoid initState() {\n$_longLine\n}',
      };
    final data = files(
      questions: [code, explainQuestion()],
      sets: [
        set(questionIds: ['dart.q1', 'dart.q2']),
      ],
    );
    await tester.runAsync(() async {
      final catalog =
          (await const ContentParser().parse(readerOf(data))).catalog;
      final repository = PracticeRepositoryImpl(
        _FakeContentRepository(catalog),
        InMemoryPracticeLocalDataSource(),
        AppClock(),
      );
      cubit = PracticeCubit(
        StartPractice(repository, const OpenPracticeGate()),
        ResumePractice(repository),
        SavePractice(repository),
        SubmitPractice(repository),
      );
      await cubit.start('dart.set1');
    });
    expect(cubit.state, isA<PracticeInProgress>());
  }

  Future<void> pumpScreen(WidgetTester tester, {double textScale = 1}) async {
    await tester.binding.setSurfaceSize(const Size(360, 800));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      I18n(
        initialLocale: const Locale('vi', 'VN'),
        child: Sizer(
          builder: (context, orientation, deviceType) => MaterialApp(
            builder: (context, child) => MediaQuery(
              data: MediaQuery.of(context).copyWith(
                textScaler: TextScaler.linear(textScale),
              ),
              child: child!,
            ),
            home: BlocProvider.value(
              value: cubit,
              child: const PracticeScreen(),
            ),
          ),
        ),
      ),
    );
    await tester.pump();
  }

  Future<void> unmount(WidgetTester tester) async {
    // Disposes the session clock before the pending-timer check.
    await tester.pumpWidget(const SizedBox());
    await tester.runAsync(cubit.close);
  }

  testWidgets('long code line scrolls instead of overflowing, at 1.3x text',
      (tester) async {
    await start(tester);
    await pumpScreen(tester, textScale: 1.3);

    expect(tester.takeException(), isNull);
    expect(
      find.textContaining('very long line', findRichText: true),
      findsOneWidget,
    );
    expect(find.byType(PracticeOptionTile), findsNWidgets(2));
    await unmount(tester);
  });

  testWidgets('selecting an option updates the UI', (tester) async {
    await start(tester);
    await pumpScreen(tester);

    await tester.ensureVisible(find.byType(PracticeOptionTile).last);
    await tester.tap(find.byType(PracticeOptionTile).last);
    await tester.pump();

    final tiles = tester
        .widgetList<PracticeOptionTile>(find.byType(PracticeOptionTile))
        .toList();
    expect(tiles.map((tile) => tile.selected), [false, true]);
    expect(tester.takeException(), isNull);
    await unmount(tester);
  });

  testWidgets('last question shows the submit CTA', (tester) async {
    await start(tester);
    await pumpScreen(tester);

    expect(find.text(Strings.practiceNext.i18n), findsOneWidget);
    await tester.tap(find.text(Strings.practiceNext.i18n));
    await tester.pump();

    expect(find.text(Strings.practiceSubmit.i18n), findsOneWidget);
    expect(find.text(Strings.practiceNext.i18n), findsNothing);
    // Self-explain: no options, the answer-out-loud hint instead.
    expect(find.byType(PracticeOptionTile), findsNothing);
    expect(
      find.textContaining(
        Strings.practiceSelfExplainHint.i18n,
        findRichText: true,
      ),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
    await unmount(tester);
  });
}
