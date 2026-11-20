// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:i18n_extension/i18n_extension.dart' show I18n;
import 'package:sizer/sizer.dart';

// Project imports:
import 'package:AppName/core/app/languages/data/localization.dart';
import 'package:AppName/features/catalog/data/datasources/user_roadmaps_local_datasource.dart';
import 'package:AppName/features/catalog/domain/entities/user_roadmap.dart';
import 'package:AppName/features/catalog/domain/usecase/filter_tracks.dart';
import 'package:AppName/features/catalog/domain/usecase/get_explore_data.dart';
import 'package:AppName/features/catalog/domain/usecase/saved_tracks.dart';
import 'package:AppName/features/catalog/domain/usecase/user_roadmaps.dart';
import 'package:AppName/features/catalog/presentation/cubit/explore_cubit.dart';
import 'package:AppName/features/catalog/presentation/cubit/roadmap_picker_cubit.dart';
import 'package:AppName/features/catalog/presentation/cubit/roadmaps_cubit.dart';
import 'package:AppName/features/catalog/presentation/widgets/roadmap_picker_view.dart';
import 'package:AppName/features/catalog/presentation/widgets/roadmap_switcher.dart';
import 'package:AppName/features/content/domain/entities/question.dart';
import 'package:AppName/features/practice/domain/usecase/find_completed_result.dart';
import 'package:AppName/features/practice/domain/usecase/practice_usecases.dart';
import 'package:AppName/features/practice/presentation/cubit/practice_cubit.dart';
import 'package:AppName/features/profile/domain/entities/learner_profile.dart';
import 'package:AppName/features/profile/domain/usecase/profile_usecases.dart';
import '../../helpers/test_graph.dart';
import '../content/content_test_data.dart';

void main() {
  late TestGraph graph;

  setUp(() async {
    graph = await TestGraph.create();
  });

  Future<void> saveProfile(
    List<String> stack, {
    ExperienceLevel experience = ExperienceLevel.junior,
  }) =>
      graph.profiles.save(
        ProfileFields(
          displayName: 'Lan',
          role: TargetRole.mobile,
          experience: experience,
          techStack: stack,
        ),
      );

  ExploreCubit newExplore() => ExploreCubit(
        GetTracks(graph.catalog),
        GetExploreDashboard(graph.catalog),
        GetProfile(graph.profiles),
        OpenTrackRoadmap(
          graph.roadmaps,
          SuggestRoadmapLevel(graph.profiles),
        ),
        WatchProgress(graph.catalog),
      );

  RoadmapsCubit newRoadmaps() => RoadmapsCubit(
        GetUserRoadmaps(graph.roadmaps),
        SelectUserRoadmap(graph.roadmaps),
        RemoveUserRoadmap(graph.roadmaps),
        GetTracks(graph.catalog),
        GetExploreDashboard(graph.catalog),
        WatchProgress(graph.catalog),
      );

  RoadmapPickerCubit newPicker() => RoadmapPickerCubit(
        GetTracks(graph.catalog),
        GetSavedTrackIds(graph.saved),
        GetUserRoadmaps(graph.roadmaps),
        SuggestRoadmapLevel(graph.profiles),
        GetProfile(graph.profiles),
        AddUserRoadmap(graph.roadmaps),
      );

  group('Explore shows only the learner roadmaps', () {
    test('tracks of the stack, in pick order', () async {
      await saveProfile(['go', 'dart']);
      final cubit = newExplore();
      await cubit.load();
      final state = cubit.state as ExploreLoaded;
      expect(state.myTracks.map((t) => t.track.id), ['go', 'dart']);
      await cubit.close();
    });

    test('falls back to available tracks when the stack matches none',
        () async {
      await saveProfile(['rust']);
      final cubit = newExplore();
      await cubit.load();
      expect(
        (cubit.state as ExploreLoaded).myTracks.map((t) => t.track.id),
        ['dart'],
      );
      await cubit.close();
    });

    test('opening a track adds it at the suggested level, then reuses it',
        () async {
      await saveProfile(['dart'], experience: ExperienceLevel.student);
      final cubit = newExplore();
      await cubit.openTrack('dart');
      expect(graph.roadmaps.active?.id, 'dart:fresher');

      await graph.roadmaps.add('dart', QuestionLevel.junior);
      await graph.roadmaps.add('go', QuestionLevel.fresher);
      await cubit.openTrack('dart');
      expect(
        graph.roadmaps.active?.trackId,
        'dart',
        reason: 'reuses an existing dart roadmap instead of adding one',
      );
      expect(graph.roadmaps.roadmaps, hasLength(3));
      await cubit.close();
    });
  });

  group('UserRoadmapsRepository', () {
    test('adding the same track + level reuses it and makes it active',
        () async {
      final repo = graph.roadmaps;
      expect(repo.active, isNull);
      await repo.add('dart', QuestionLevel.junior);
      await repo.add('flutter', QuestionLevel.fresher);
      expect(repo.active?.id, 'flutter:fresher');

      await repo.add('dart', QuestionLevel.junior);
      expect(repo.roadmaps.map((r) => r.id), ['dart:junior', 'flutter:fresher']);
      expect(repo.active?.id, 'dart:junior');
    });

    test('removing the active one activates the newest remaining', () async {
      final repo = graph.roadmaps;
      await repo.add('a', QuestionLevel.fresher);
      await repo.add('b', QuestionLevel.fresher);
      await repo.select('a:fresher');
      await repo.remove('a:fresher');
      expect(repo.active?.id, 'b:fresher');
      await repo.remove('b:fresher');
      expect(repo.active, isNull);
    });

    test('json round trip skips unknown levels', () {
      final data = UserRoadmapsJson.fromJson({
        'active': 'dart:junior',
        'items': [
          {'trackId': 'dart', 'level': 'junior', 'addedAt': 0},
          {'trackId': 'go', 'level': 'principal', 'addedAt': 0},
        ],
      });
      expect(data.roadmaps.map((r) => r.id), ['dart:junior']);
      expect(data.activeId, 'dart:junior');
    });

    test('a roadmap covers every level up to its own', () {
      final roadmap = UserRoadmap(
        trackId: 'dart',
        level: QuestionLevel.junior,
        addedAt: DateTime(2026),
      );
      expect(roadmap.levels, [QuestionLevel.fresher, QuestionLevel.junior]);
      expect(roadmap.includes(QuestionLevel.middle), isFalse);
    });
  });

  group('RoadmapPickerCubit', () {
    test('prefills from the profile and adds the roadmap on confirm',
        () async {
      await saveProfile(['go', 'dart'], experience: ExperienceLevel.middle);
      final cubit = newPicker();
      await cubit.load();
      var state = cubit.state as RoadmapPickerLoaded;
      expect(
        state.selectedTrackId,
        'dart',
        reason: 'go is not available, so the next stack track',
      );
      expect(state.level, QuestionLevel.middle);

      cubit.selectTrack('go');
      expect((cubit.state as RoadmapPickerLoaded).selectedTrackId, 'dart');

      cubit.selectLevel(QuestionLevel.junior);
      await cubit.confirm();
      state = cubit.state as RoadmapPickerLoaded;
      expect(state.done, isTrue);
      expect(graph.roadmaps.active?.id, 'dart:junior');
      await cubit.close();
    });

    test('search and category filter the languages; existing is flagged',
        () async {
      await graph.roadmaps.add('dart', QuestionLevel.fresher);
      final cubit = newPicker();
      await cubit.load();
      RoadmapPickerLoaded state() => cubit.state as RoadmapPickerLoaded;

      cubit.search('GO back');
      expect(state().visibleTracks.map((t) => t.track.id), ['go']);
      cubit.search('null safety');
      expect(state().visibleTracks.map((t) => t.track.id), ['dart']);
      cubit
        ..search('')
        ..selectCategory('backend');
      expect(state().visibleTracks, isEmpty);

      cubit
        ..selectTrack('dart')
        ..selectLevel(QuestionLevel.fresher);
      expect(state().isExisting, isTrue);
      await cubit.close();
    });
  });

  group('RoadmapsCubit', () {
    test('no roadmap until one is picked, then follows the active one',
        () async {
      final cubit = newRoadmaps();
      await cubit.load();
      expect((cubit.state as RoadmapsLoaded).active, isNull);

      await graph.roadmaps.add('dart', QuestionLevel.junior);
      await Future<void>.delayed(Duration.zero);
      var state = cubit.state as RoadmapsLoaded;
      expect(state.active?.id, 'dart:junior');

      await graph.roadmaps.add('dart', QuestionLevel.fresher);
      await cubit.select('dart:junior');
      await Future<void>.delayed(Duration.zero);
      state = cubit.state as RoadmapsLoaded;
      expect(state.active?.id, 'dart:junior');
      expect(state.roadmaps, hasLength(2));

      await cubit.remove('dart:junior');
      await Future<void>.delayed(Duration.zero);
      expect((cubit.state as RoadmapsLoaded).active?.id, 'dart:fresher');
      await cubit.close();
    });
  });

  test('track detail keeps questions and sets up to the roadmap level',
      () async {
    final data = files(
      questions: [
        choiceQuestion(),
        explainQuestion(),
        choiceQuestion(id: 'dart.q3')..['level'] = 'middle',
      ],
      sets: [
        set(),
        set(id: 'dart.pro', questionIds: ['dart.q3'])
          ..['accessPlanId'] = 'premium',
      ],
    );
    final levelGraph = await TestGraph.create(data: data);

    final junior = (await levelGraph.catalog
            .getTrackDetail('dart', maxLevel: QuestionLevel.junior))
        .value!;
    expect(junior.maxLevel, QuestionLevel.junior);
    expect(junior.questionCount, 2);
    expect(junior.sets.map((s) => s.set.id), ['dart.set1']);

    final middle = (await levelGraph.catalog
            .getTrackDetail('dart', maxLevel: QuestionLevel.middle))
        .value!;
    expect(middle.questionCount, 3);
    expect(middle.sets.map((s) => s.set.id), ['dart.set1', 'dart.pro']);
  });

  test('normalize folds Vietnamese diacritics', () {
    expect(FilterTracks.normalize('Lập Trình ĐỘNG'), 'lap trinh dong');
  });

  group('FindCompletedResult', () {
    late FindCompletedResult find;

    setUp(() => find = FindCompletedResult(graph.content, graph.practice));

    Future<void> play({List<String>? only}) async {
      final cubit = PracticeCubit(
        StartPractice(graph.practice),
        ResumePractice(graph.practice),
        SavePractice(graph.practice),
        SubmitPractice(graph.practice),
      );
      await cubit.start('dart.set1', onlyQuestionIds: only);
      cubit.selectOption('a');
      graph.clock.value = graph.clock.value.add(const Duration(minutes: 1));
      await cubit.submit();
      await cubit.close();
    }

    test('null before any attempt', () async {
      expect(await find('dart.set1'), isNull);
    });

    test('a subset attempt does not complete the whole set', () async {
      await play(only: ['dart.q1']);
      expect(await find('dart.set1'), isNull);
      expect(
        await find('dart.set1', onlyQuestionIds: ['dart.q1']),
        isNotNull,
        reason: 'but completes that topic',
      );
    });

    test('returns the latest full attempt', () async {
      await play();
      await play();
      final results = await graph.practice.getResults();
      expect((await find('dart.set1'))?.sessionId, results.last.sessionId);
      expect(await find('dart.other'), isNull);
    });
  });

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
            home: Scaffold(body: child),
          ),
        ),
      ),
    );
    await tester.pump();
  }

  testWidgets('picker lets the learner choose language and level',
      (tester) async {
    late RoadmapPickerCubit cubit;
    await tester.runAsync(() async {
      await saveProfile(['dart']);
      cubit = newPicker();
      await cubit.load();
    });
    await pumpSmall(
      tester,
      BlocProvider.value(
        value: cubit,
        child: const RoadmapPickerView(title: 'Title', subtitle: 'Subtitle'),
      ),
    );
    expect(tester.takeException(), isNull);
    expect(find.text('Title'), findsOneWidget);
    expect(find.text(Strings.pickerConfirm.i18n), findsOneWidget);

    final senior = find.text('Senior · ${Strings.pickerPremium.i18n}');
    await tester.scrollUntilVisible(
      senior,
      200,
      scrollable: find
          .descendant(
            of: find.byType(ListView),
            matching: find.byType(Scrollable),
          )
          .first,
    );
    await tester.tap(senior);
    await tester.pump();
    expect(
      (cubit.state as RoadmapPickerLoaded).level,
      QuestionLevel.senior,
    );
    expect(tester.takeException(), isNull);

    await tester.pumpWidget(const SizedBox());
    await tester.runAsync(cubit.close);
  });

  testWidgets('switcher lists roadmaps and selects one', (tester) async {
    final flutter = UserRoadmap(
      trackId: 'flutter',
      level: QuestionLevel.junior,
      addedAt: DateTime(2026),
    );
    final dart = UserRoadmap(
      trackId: 'dart',
      level: QuestionLevel.fresher,
      addedAt: DateTime(2026),
    );
    String? selected;
    var added = false;
    await pumpSmall(
      tester,
      Builder(
        builder: (context) => RoadmapSwitcher(
          active: flutter,
          roadmaps: [flutter, dart],
          tracks: const {},
          onSelect: (id) => selected = id,
          onRemove: (_) {},
          onAdd: () => added = true,
        ),
      ),
    );
    expect(find.text('flutter · Fresher / Junior'), findsOneWidget);

    await tester.tap(find.byType(RoadmapSwitcher));
    await tester.pumpAndSettle();
    expect(find.text(Strings.switcherTitle.i18n), findsOneWidget);
    await tester.tap(find.text('dart · Fresher'));
    await tester.pumpAndSettle();
    expect(selected, 'dart:fresher');

    await tester.tap(find.byType(RoadmapSwitcher));
    await tester.pumpAndSettle();
    await tester.tap(find.text(Strings.switcherAdd.i18n));
    await tester.pumpAndSettle();
    expect(added, isTrue);
    expect(tester.takeException(), isNull);
  });

  group('topic review covers the whole topic', () {
    late TestGraph topicGraph;

    setUp(() async {
      // null_safety: q1 (fresher, set A), q2 (junior, set B), q3 (middle,
      // premium set P). Each authored set holds only part of the topic.
      final data = files(
        questions: [
          choiceQuestion(),
          explainQuestion(),
          choiceQuestion(id: 'dart.q3')..['level'] = 'middle',
        ],
        sets: [
          set(id: 'dart.a', questionIds: ['dart.q1']),
          set(id: 'dart.b', questionIds: ['dart.q2']),
          set(id: 'dart.p', questionIds: ['dart.q3'])
            ..['accessPlanId'] = 'premium',
        ],
      );
      topicGraph = await TestGraph.create(data: data);
    });

    test('the topic card count matches the questions practiced', () async {
      final detail = (await topicGraph.catalog
              .getTrackDetail('dart', maxLevel: QuestionLevel.junior))
          .value!;
      final topic = detail.progress.topics.single;
      expect(topic.total, 2);

      final target = detail.topicPractice('null_safety')!;
      expect(target.setId, 'dart.topic.null_safety.junior');
      final bundle = (await topicGraph.practice.startSession(target.setId))
          .value!;
      expect(
        bundle.questions.map((q) => q.id),
        ['dart.q1', 'dart.q2'],
        reason: 'spans sets A and B, excludes the middle question',
      );
      expect(bundle.set.isFree, isTrue);
    });

    test('a middle roadmap topic set includes premium questions', () async {
      final detail = (await topicGraph.catalog
              .getTrackDetail('dart', maxLevel: QuestionLevel.middle))
          .value!;
      final setId = detail.topicPractice('null_safety')!.setId;
      final bundle = (await topicGraph.practice.startSession(setId)).value!;
      expect(bundle.questions, hasLength(3));
      expect(bundle.set.accessPlanId, 'premium');
    });

    test('generated topic sets stay out of set lists and counts', () async {
      final tracks = (await topicGraph.catalog.getTracks()).value!;
      final dart = tracks.firstWhere((t) => t.track.id == 'dart');
      expect(dart.setCount, 3);

      final detail = (await topicGraph.catalog.getTrackDetail('dart')).value!;
      expect(detail.sets.map((s) => s.set.id), ['dart.a', 'dart.b', 'dart.p']);
    });
  });
}
