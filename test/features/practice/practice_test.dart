// Package imports:
import 'package:flutter_test/flutter_test.dart';

// Project imports:
import 'package:AppName/core/helpers/app_clock.dart';
import 'package:AppName/core/utils/dio_api/result.dart';
import 'package:AppName/features/content/data/parsers/content_parser.dart';
import 'package:AppName/features/content/domain/entities/content_catalog.dart';
import 'package:AppName/features/content/domain/repositories/content_repository.dart';
import 'package:AppName/features/practice/data/repositories/practice_repository_impl.dart';
import 'package:AppName/features/practice/domain/entities/session_result.dart';
import 'package:AppName/features/practice/domain/usecase/practice_usecases.dart';
import 'package:AppName/features/practice/presentation/cubit/practice_cubit.dart';
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
  late PracticeRepositoryImpl repository;
  late _FixedClock clock;

  setUp(() async {
    // q1, q3: auto-graded (answer "a"); q2: self-explain; q4: auto-graded.
    final data = files(
      questions: [
        choiceQuestion(),
        explainQuestion(),
        choiceQuestion(id: 'dart.q3'),
        choiceQuestion(id: 'dart.q4'),
      ],
      sets: [
        set(questionIds: ['dart.q1', 'dart.q2', 'dart.q3', 'dart.q4'])
          ..['durationMinutes'] = 10,
      ],
    );
    final catalog = (await const ContentParser().parse(readerOf(data))).catalog;
    clock = _FixedClock();
    repository = PracticeRepositoryImpl(_FakeContentRepository(catalog), clock);
  });

  PracticeCubit newCubit() => PracticeCubit(
        StartPractice(repository),
        SavePractice(repository),
        SubmitPractice(repository),
      );

  test('scores only auto-graded questions, skipped counts as wrong', () async {
    final cubit = newCubit();
    await cubit.start('dart.set1');

    final session = (cubit.state as PracticeInProgress).bundle.session;
    expect(session.endsAt, clock.value.add(const Duration(minutes: 10)));

    cubit.selectOption('a'); // q1 correct
    cubit.goTo(2);
    cubit.selectOption('b'); // q3 wrong
    // q4 skipped, q2 self-explain
    clock.value = clock.value.add(const Duration(minutes: 3));
    await cubit.submit();

    expect(cubit.state, isA<PracticeSubmitted>());
    final bundle = (await repository.getResult(session.id)).value!;
    final result = bundle.result;
    expect(result.gradedCount, 3);
    expect(result.correctCount, 1);
    expect(result.incorrectCount, 1);
    expect(result.skippedCount, 1);
    expect(result.selfCheckCount, 1);
    expect(result.scorePercent, 33);
    expect(result.duration, const Duration(minutes: 3));
    expect(
      result.mistakes.map((item) => item.questionId),
      ['dart.q3', 'dart.q4'],
    );
    expect(result.items.first.contentVersion, 1);
  });

  test('a session has exactly one result even when submitted twice', () async {
    final cubit = newCubit();
    await cubit.start('dart.set1');
    final id = (cubit.state as PracticeInProgress).bundle.session.id;
    cubit.selectOption('a');

    final manual = repository.submit(id);
    final timer = repository.submit(id, timedOut: true);
    final results = await Future.wait([manual, timer]);

    expect(results[0].value!.result, results[1].value!.result);
    expect(results[0].value!.result.timedOut, isFalse);

    // Answers changed after submit are ignored.
    cubit.selectOption('b');
    final again = await repository.getResult(id);
    expect(again.value!.result.correctCount, 1);
  });

  test('retry mistakes starts a session with only those questions', () async {
    final cubit = newCubit();
    await cubit.start('dart.set1', onlyQuestionIds: ['dart.q4', 'dart.q1']);
    final session = (cubit.state as PracticeInProgress).bundle.session;
    expect(session.questionIds, ['dart.q1', 'dart.q4']);
  });

  test('unknown set is not found', () async {
    final cubit = newCubit();
    await cubit.start('nope');
    expect(cubit.state, isA<PracticeNotFound>());
  });

  test('flag toggles and navigation clamps to bounds', () async {
    final cubit = newCubit();
    await cubit.start('dart.set1');
    cubit.toggleFlag();
    cubit.previous();
    var session = (cubit.state as PracticeInProgress).bundle.session;
    expect(session.flagged, {'dart.q1'});
    expect(session.currentIndex, 0);

    cubit.goTo(99);
    session = (cubit.state as PracticeInProgress).bundle.session;
    expect(session.currentIndex, 3);
    expect(session.isLastQuestion, isTrue);
    expect(AnswerStatus.selfCheck.isGraded, isFalse);
  });
}
