// Dart imports:
import 'dart:math' as math;

// Package imports:
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:i18n_extension/i18n_extension.dart' show I18n;
import 'package:material_ui/material_ui.dart';
import 'package:sizer/sizer.dart';

// Project imports:
import 'package:interview_practice/core/app/languages/data/localization.dart';
import 'package:interview_practice/core/helpers/app_clock.dart';
import 'package:interview_practice/core/utils/dio_api/result.dart';
import 'package:interview_practice/features/catalog/data/datasources/mock_dashboard_datasource.dart';
import 'package:interview_practice/features/catalog/data/repositories/catalog_repository_impl.dart';
import 'package:interview_practice/features/catalog/data/repositories/saved_tracks_repository_impl.dart';
import 'package:interview_practice/features/catalog/data/repositories/user_roadmaps_repository_impl.dart';
import 'package:interview_practice/features/catalog/domain/usecase/get_explore_data.dart';
import 'package:interview_practice/features/content/data/parsers/content_parser.dart';
import 'package:interview_practice/features/content/domain/entities/content_catalog.dart';
import 'package:interview_practice/features/content/domain/entities/localized_text.dart';
import 'package:interview_practice/features/content/domain/entities/quiz_set.dart';
import 'package:interview_practice/features/content/domain/entities/track.dart';
import 'package:interview_practice/features/content/domain/repositories/content_repository.dart';
import 'package:interview_practice/features/practice/data/repositories/practice_repository_impl.dart';
import 'package:interview_practice/features/practice/domain/entities/practice_hub.dart';
import 'package:interview_practice/features/practice/domain/usecase/get_practice_hub.dart';
import 'package:interview_practice/features/practice/domain/usecase/practice_usecases.dart';
import 'package:interview_practice/features/practice/presentation/cubit/practice_cubit.dart';
import 'package:interview_practice/features/practice/presentation/cubit/practice_hub_cubit.dart';
import 'package:interview_practice/features/practice/presentation/screens/practice_hub_screen.dart';
import 'package:interview_practice/features/profile/data/repositories/profile_repository_impl.dart';
import '../../helpers/in_memory_avatar_datasource.dart';
import '../../helpers/in_memory_practice_datasource.dart';
import '../../helpers/in_memory_profile_datasource.dart';
import '../../helpers/in_memory_saved_tracks_datasource.dart';
import '../../helpers/in_memory_user_roadmaps_datasource.dart';
import '../../helpers/open_practice_gate.dart';
import '../content/content_test_data.dart';

class _FakeContentRepository implements ContentRepository {
  final ContentCatalog catalog;

  _FakeContentRepository(this.catalog);

  @override
  Future<Result<ContentCatalog>> loadCatalog() async => Result.success(catalog);
}

Track catalogTrack() => const Track(
      id: 'dart',
      name: LocalizedText({'vi': 'Dart'}),
      order: 1,
      isAvailable: true,
      topics: [],
    );

QuizSet catalogSet(List<String> questionIds) => QuizSet(
      id: 'dart.set',
      trackId: 'dart',
      title: const LocalizedText({'vi': 'Bộ đề'}),
      questionIds: questionIds,
    );

class _FixedClock extends AppClock {
  DateTime value = DateTime(2026, 11, 20, 9);

  @override
  DateTime now() => value;
}

void main() {
  late _FixedClock clock;
  late PracticeRepositoryImpl practice;
  late CatalogRepositoryImpl catalog;
  late GetPracticeHub getHub;

  Future<void> setUpRepositories() async {
    // Answer "a" is correct for every choice question; q2 is self-explain.
    final data = files(
      questions: [
        for (var i = 1; i <= 7; i++)
          if (i == 2) explainQuestion() else choiceQuestion(id: 'dart.q$i'),
      ],
      sets: [
        set(questionIds: ['dart.q1', 'dart.q2', 'dart.q3']),
        set(
          id: 'dart.set2',
          questionIds: ['dart.q4', 'dart.q5', 'dart.q6', 'dart.q7', 'dart.q1'],
        ),
      ],
    );
    final content = _FakeContentRepository(
      (await const ContentParser().parse(readerOf(data))).catalog,
    );
    clock = _FixedClock();
    final profiles = ProfileRepositoryImpl(
      InMemoryProfileLocalDataSource(),
      InMemoryAvatarLocalDataSource(),
      clock,
    );
    practice = PracticeRepositoryImpl(
      content,
      InMemoryPracticeLocalDataSource(),
      clock,
    );
    catalog = CatalogRepositoryImpl(
      content,
      practice,
      profiles,
      SavedTracksRepositoryImpl(InMemorySavedTracksLocalDataSource()),
      UserRoadmapsRepositoryImpl(
        InMemoryUserRoadmapsLocalDataSource(),
        AppClock(),
      ),
      MockDashboardDataSource(),
      clock,
    );
    getHub = GetPracticeHub(content, practice, profiles);
  }

  /// Runs a session of [setId] answering per question id, then submits.
  Future<void> play(
    String setId,
    Map<String, String> answers, {
    List<String>? only,
  }) async {
    final cubit = PracticeCubit(
      StartPractice(practice, const OpenPracticeGate()),
      ResumePractice(practice),
      SavePractice(practice),
      SubmitPractice(practice),
    );
    await cubit.start(setId, onlyQuestionIds: only);
    final ids = (cubit.state as PracticeInProgress).bundle.session.questionIds;
    for (var i = 0; i < ids.length; i++) {
      cubit.goTo(i);
      if (answers[ids[i]] case final option?) cubit.selectOption(option);
    }
    clock.value = clock.value.add(const Duration(minutes: 5));
    await cubit.submit();
    await cubit.close();
  }

  group('GetPracticeHub', () {
    setUp(setUpRepositories);

    test('empty history', () async {
      final hub = (await getHub()).value!;
      expect(hub.mistakes, isEmpty);
      expect(hub.history, isEmpty);
      expect(hub.sessionCount, 0);
      expect(hub.averageScorePercent, 0);
      expect(
        hub.quickPractices.single.set.id,
        'dart.set2',
        reason: 'largest free set of the only available track',
      );
    });

    test('groups mistakes by the set of the latest attempt', () async {
      // set1: q1 correct, q3 wrong. set2: q4 wrong, q5..q7 skipped, q1 wrong.
      await play('dart.set1', {'dart.q1': 'a', 'dart.q3': 'b'});
      await play('dart.set2', {'dart.q4': 'b', 'dart.q1': 'b'});

      final hub = (await getHub()).value!;
      expect(
        {for (final g in hub.mistakes) g.set.id: g.questionIds},
        {
          'dart.set2': ['dart.q4', 'dart.q5', 'dart.q6', 'dart.q7', 'dart.q1'],
          'dart.set1': ['dart.q3'],
        },
      );
      expect(hub.mistakeCount, 6);
      expect(hub.sessionCount, 2);
      // set1: 1/2 = 50%; set2: 0/5 = 0%.
      expect(hub.averageScorePercent, 25);
      expect(
        hub.history.map((entry) => entry.set.id),
        ['dart.set2', 'dart.set1'],
        reason: 'newest first',
      );
    });

    test('fixing a mistake removes it from the review list', () async {
      await play('dart.set1', {'dart.q1': 'b', 'dart.q3': 'b'});
      await play(
        'dart.set1',
        {'dart.q1': 'a'},
        only: ['dart.q1', 'dart.q3'],
      );

      final hub = (await getHub()).value!;
      expect(hub.mistakes.single.questionIds, ['dart.q3']);
    });

    test('quick practice picks at most 5 random questions', () {
      final quick = QuickPractice(
        track: catalogTrack(),
        set: catalogSet(List.generate(8, (i) => 'q$i')),
      );
      final picked = quick.pickQuestions(math.Random(1))!;
      expect(picked, hasLength(5));
      expect(picked.toSet(), hasLength(5));
      expect(quick.questionCount, 5);
      expect(
        QuickPractice(track: catalogTrack(), set: catalogSet(['q1']))
            .pickQuestions(),
        isNull,
      );
    });
  });

  testWidgets('hub screen renders sections on a small screen', (tester) async {
    late PracticeHubCubit cubit;
    await tester.runAsync(() async {
      await setUpRepositories();
      await play('dart.set1', {'dart.q1': 'a', 'dart.q3': 'b'});
      cubit = PracticeHubCubit(
        getHub,
        GetExploreDashboard(catalog),
        WatchProgress(catalog),
      );
      await cubit.load();
    });

    await tester.binding.setSurfaceSize(const Size(320, 640));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      I18n(
        initialLocale: const Locale('vi', 'VN'),
        child: Sizer(
          builder: (context, orientation, deviceType) => MaterialApp(
            home: BlocProvider.value(
              value: cubit,
              child: const PracticeHubScreen(),
            ),
          ),
        ),
      ),
    );
    await tester.pump();

    expect(tester.takeException(), isNull);
    expect(find.text(Strings.hubMistakesTitle.i18n), findsOneWidget);
    expect(
      find.text(Strings.hubMistakeCount.i18n.fill([1])),
      findsNWidgets(2),
      reason: 'header subtitle and the mistakes row',
    );
    expect(find.text(Strings.hubTitle.i18n), findsOneWidget);

    await tester.pumpWidget(const SizedBox());
    await tester.runAsync(cubit.close);
  });
}
