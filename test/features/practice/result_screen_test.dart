// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sizer/sizer.dart';

// Project imports:
import 'package:interview_practice/core/helpers/app_clock.dart';
import 'package:interview_practice/core/utils/dio_api/result.dart';
import 'package:interview_practice/features/content/data/parsers/content_parser.dart';
import 'package:interview_practice/features/content/domain/entities/content_catalog.dart';
import 'package:interview_practice/features/content/domain/repositories/content_repository.dart';
import 'package:interview_practice/features/practice/data/repositories/practice_repository_impl.dart';
import 'package:interview_practice/features/practice/domain/usecase/practice_usecases.dart';
import 'package:interview_practice/features/practice/presentation/cubit/practice_cubit.dart';
import 'package:interview_practice/features/practice/presentation/cubit/result_cubit.dart';
import 'package:interview_practice/features/practice/presentation/screens/result_screen.dart';
import 'package:interview_practice/features/practice/presentation/widgets/result_review_card.dart';
import '../../helpers/in_memory_practice_datasource.dart';
import '../../helpers/open_practice_gate.dart';
import '../content/content_test_data.dart';

class _FakeContentRepository implements ContentRepository {
  final ContentCatalog catalog;

  _FakeContentRepository(this.catalog);

  @override
  Future<Result<ContentCatalog>> loadCatalog() async => Result.success(catalog);
}

class _FixedClock extends AppClock {
  DateTime value = DateTime(2026, 11, 16, 9);

  @override
  DateTime now() => value;
}

void main() {
  testWidgets('shows score, mistakes and updates the self-check list',
      (tester) async {
    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    late ResultCubit cubit;
    await tester.runAsync(() async {
      final data = files(
        questions: [
          choiceQuestion(),
          explainQuestion(),
          choiceQuestion(id: 'dart.q3'),
          choiceQuestion(id: 'dart.q4'),
        ],
        sets: [
          set(questionIds: ['dart.q1', 'dart.q2', 'dart.q3', 'dart.q4']),
        ],
      );
      final catalog =
          (await const ContentParser().parse(readerOf(data))).catalog;
      final clock = _FixedClock();
      final repository = PracticeRepositoryImpl(
        _FakeContentRepository(catalog),
        InMemoryPracticeLocalDataSource(),
        clock,
      );
      final practice = PracticeCubit(
        StartPractice(repository, const OpenPracticeGate()),
        ResumePractice(repository),
        SavePractice(repository),
        SubmitPractice(repository),
      );
      await practice.start('dart.set1');
      final sessionId =
          (practice.state as PracticeInProgress).bundle.session.id;
      practice.selectOption('a'); // q1 correct
      practice.goTo(2);
      practice.selectOption('b'); // q3 wrong, q4 skipped, q2 self-explain
      clock.value = clock.value.add(const Duration(minutes: 3, seconds: 42));
      await practice.submit();

      cubit = ResultCubit(GetPracticeResult(repository));
      await cubit.load(sessionId);
    });
    addTearDown(cubit.close);

    await tester.pumpWidget(
      Sizer(
        builder: (context, orientation, deviceType) => MaterialApp(
          home: BlocProvider.value(
            value: cubit,
            child: const ResultScreen(),
          ),
        ),
      ),
    );
    await tester.pump();

    expect(find.text('1/3'), findsOneWidget);
    expect(find.textContaining('33%'), findsOneWidget);
    expect(find.text('03:42'), findsOneWidget);
    expect(find.byType(ResultMistakeCard), findsNWidgets(2));

    final checklist = find.byType(ResultSelfCheckCard);
    await tester.scrollUntilVisible(
      checklist,
      300,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.textContaining('0/1'), findsOneWidget);

    final keyPoint = find.text('Ý 1');
    await tester.ensureVisible(keyPoint);
    await tester.pump();
    await tester.tap(keyPoint);
    await tester.pump();

    expect(find.textContaining('1/1'), findsOneWidget);
    expect((cubit.state as ResultLoaded).checkedPoints['dart.q2'], {0});
  });
}
