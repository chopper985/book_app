// Dart imports:
import 'dart:convert';
import 'dart:math' as math;

// Package imports:
import 'package:flutter_test/flutter_test.dart';

// Project imports:
import 'package:interview_practice/features/catalog/domain/entities/user_roadmap.dart';
import 'package:interview_practice/features/catalog/domain/usecase/get_explore_data.dart';
import 'package:interview_practice/features/catalog/domain/usecase/saved_tracks.dart';
import 'package:interview_practice/features/catalog/domain/usecase/user_roadmaps.dart';
import 'package:interview_practice/features/catalog/presentation/cubit/position_detail_cubit.dart';
import 'package:interview_practice/features/catalog/presentation/cubit/roadmap_picker_cubit.dart';
import 'package:interview_practice/features/catalog/presentation/cubit/roadmaps_cubit.dart';
import 'package:interview_practice/features/content/data/parsers/content_parser.dart';
import 'package:interview_practice/features/content/domain/entities/content_catalog.dart';
import 'package:interview_practice/features/content/domain/entities/content_issue.dart';
import 'package:interview_practice/features/content/domain/entities/question.dart';
import 'package:interview_practice/features/content/domain/entities/quiz_set.dart';
import 'package:interview_practice/features/content/domain/usecase/validate_content.dart';
import 'package:interview_practice/features/practice/domain/usecase/practice_usecases.dart';
import 'package:interview_practice/features/practice/presentation/cubit/practice_cubit.dart';
import 'package:interview_practice/features/profile/domain/entities/learner_profile.dart';
import 'package:interview_practice/features/profile/domain/usecase/profile_usecases.dart';
import '../../helpers/test_graph.dart';
import '../content/content_test_data.dart';

/// Two available tracks: dart (q1 fresher, q2 junior, q3 middle) and sql
/// (s1 fresher), plus a Back-end position using dart as main and sql as core.
Map<String, String> positionData({List<String>? coreTrackIds}) {
  final tracks = validTracks();
  (tracks['tracks']! as List).add({
    'id': 'sql',
    'name': {'vi': 'SQL'},
    'order': 3,
    'available': true,
    'topics': [
      {
        'id': 'joins',
        'name': {'vi': 'JOIN'},
      },
    ],
  });
  return {
    ...files(
      tracks: tracks,
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
    ),
    'sql/questions.json': jsonEncode({
      'questions': [
        choiceQuestion(id: 'sql.s1')
          ..['trackId'] = 'sql'
          ..['topicId'] = 'joins',
      ],
    }),
    'sql/sets.json': jsonEncode({
      'sets': [
        set(id: 'sql.set1', questionIds: ['sql.s1'])..['trackId'] = 'sql',
      ],
    }),
    'positions.json': jsonEncode({
      'positions': [
        {
          'id': 'backend',
          'name': {'vi': 'Back-end', 'en': 'Back-end'},
          'options': [
            {
              'id': 'dart',
              'name': {'vi': 'Dart'},
              'trackIds': ['dart'],
            },
            {
              'id': 'manual',
              'name': {'vi': 'Chỉ kiến thức chung'},
              'trackIds': <String>[],
            },
          ],
          'coreTrackIds': coreTrackIds ?? ['sql'],
        },
      ],
    }),
  };
}

void main() {
  group('content', () {
    test('positions are parsed and validated', () async {
      final parsed =
          await const ContentParser().parse(readerOf(positionData()));
      expect(parsed.issues, isEmpty);
      expect(const ValidateContent()(parsed.catalog), isEmpty);
      final position = parsed.catalog.positionById('backend')!;
      expect(position.trackIdsFor(position.optionById('dart')!), [
        'dart',
        'sql',
      ]);
    });

    test('a position may only use available tracks', () async {
      final parsed = await const ContentParser()
          .parse(readerOf(positionData(coreTrackIds: ['sql', 'go'])));
      final issues = const ValidateContent()(parsed.catalog);
      expect(
        issues.map((issue) => (issue.code, issue.detail)),
        [(ContentIssueCode.missingReference, 'go')],
      );
    });

    test('content without positions.json still parses', () async {
      final parsed = await const ContentParser().parse(readerOf(files()));
      expect(parsed.issues, isEmpty);
      expect(parsed.catalog.positions, isEmpty);
    });

    test('mock pools mix option and core tracks up to the level', () async {
      final catalog =
          (await const ContentParser().parse(readerOf(positionData())))
              .catalog
              .withTopicSets();
      QuizSet lookup(String id) =>
          catalog.sets.firstWhere((set) => set.id == id);

      final junior = lookup(
        ContentCatalog.positionSetId('backend', 'dart', QuestionLevel.junior),
      );
      expect(junior.questionIds, ['dart.q1', 'dart.q2', 'sql.s1']);
      expect(junior.isFree, isTrue);
      expect(junior.isGenerated, isTrue);
      expect(junior.durationMinutes, ContentCatalog.positionMockMinutes);

      final middle = lookup(
        ContentCatalog.positionSetId('backend', 'dart', QuestionLevel.middle),
      );
      expect(middle.questionIds, contains('dart.q3'));
      expect(middle.accessPlanId, ContentCatalog.premiumPlanId);

      final manual = lookup(
        ContentCatalog.positionSetId('backend', 'manual', QuestionLevel.junior),
      );
      expect(manual.questionIds, ['sql.s1'], reason: 'core tracks only');
      expect(catalog.setsOfTrack('dart').every((s) => !s.isGenerated), isTrue);
    });
  });

  group('position roadmaps', () {
    late TestGraph graph;

    setUp(() async {
      graph = await TestGraph.create(data: positionData());
    });

    test('adding uses the option main track as icon and is reused', () async {
      final add = AddPositionRoadmap(graph.roadmaps, graph.catalog);
      final roadmap = (await add('backend', 'dart', QuestionLevel.junior))!;
      expect(roadmap.isPosition, isTrue);
      expect(roadmap.trackId, 'dart');
      expect(roadmap.id, 'position:backend:dart:junior');

      final manual = (await add('backend', 'manual', QuestionLevel.fresher))!;
      expect(manual.trackId, 'sql', reason: 'no main track: first core one');

      await add('backend', 'dart', QuestionLevel.junior);
      expect(graph.roadmaps.roadmaps, hasLength(2));
      expect(graph.roadmaps.active?.id, 'position:backend:dart:junior');
      expect(await add('backend', 'nope', QuestionLevel.junior), isNull);
    });

    test('detail tracks progress per track and overall', () async {
      final practice = PracticeCubit(
        StartPractice(graph.practice),
        ResumePractice(graph.practice),
        SavePractice(graph.practice),
        SubmitPractice(graph.practice),
      );
      await practice.start('sql.set1');
      practice.selectOption('a');
      await practice.submit();
      await practice.close();

      final roadmap = (await AddPositionRoadmap(graph.roadmaps, graph.catalog)(
        'backend',
        'dart',
        QuestionLevel.junior,
      ))!;
      final cubit = PositionDetailCubit(
        GetPositionDetail(graph.catalog),
        WatchProgress(graph.catalog),
      );
      await cubit.load(roadmap);
      final detail = (cubit.state as PositionDetailLoaded).detail;

      expect(
        detail.tracks.map((t) => (t.track.id, t.isMain, t.answered, t.total)),
        [('dart', true, 0, 2), ('sql', false, 1, 1)],
      );
      expect(detail.total, 3);
      expect(detail.answered, 1);
      expect(detail.mockQuestionIds, ['dart.q1', 'dart.q2', 'sql.s1']);
      expect(detail.mockIsPremium, isFalse);
      await cubit.close();
    });

    test('mock test picks at most 20 random questions', () {
      final pool = List.generate(50, (i) => 'q$i');
      final picked =
          PositionDetailCubit.pickMockQuestions(pool, math.Random(3))!;
      expect(picked, hasLength(ContentCatalog.positionMockQuestions));
      expect(picked.toSet(), hasLength(ContentCatalog.positionMockQuestions));
      expect(PositionDetailCubit.pickMockQuestions(['a', 'b']), isNull);
    });

    test('picker position mode prefills from the profile role', () async {
      await graph.profiles.save(
        const ProfileFields(
          displayName: 'Lan',
          role: TargetRole.backend,
          experience: ExperienceLevel.junior,
          techStack: ['dart'],
        ),
      );
      final cubit = RoadmapPickerCubit(
        GetTracks(graph.catalog),
        GetSavedTrackIds(graph.saved),
        GetUserRoadmaps(graph.roadmaps),
        SuggestRoadmapLevel(graph.profiles),
        GetProfile(graph.profiles),
        AddUserRoadmap(graph.roadmaps),
        GetPositions(graph.catalog),
        AddPositionRoadmap(graph.roadmaps, graph.catalog),
      );
      await cubit.load();
      cubit.selectMode(RoadmapPickerMode.position);
      var state = cubit.state as RoadmapPickerLoaded;
      expect(state.positionId, 'backend');
      expect(state.optionId, 'dart', reason: 'matches the profile stack');
      expect(state.positionTrackIds, ['dart', 'sql']);
      expect(state.canConfirm, isTrue);

      cubit.selectOption('manual');
      await cubit.confirm();
      state = cubit.state as RoadmapPickerLoaded;
      expect(state.done, isTrue);
      expect(graph.roadmaps.active?.id, 'position:backend:manual:junior');
      await cubit.close();
    });

    test('roadmaps tab lists position roadmaps with their position', () async {
      await AddPositionRoadmap(graph.roadmaps, graph.catalog)(
        'backend',
        'dart',
        QuestionLevel.fresher,
      );
      final cubit = RoadmapsCubit(
        GetUserRoadmaps(graph.roadmaps),
        SelectUserRoadmap(graph.roadmaps),
        RemoveUserRoadmap(graph.roadmaps),
        GetTracks(graph.catalog),
        GetExploreDashboard(graph.catalog),
        GetPositions(graph.catalog),
        WatchProgress(graph.catalog),
      );
      await cubit.load();
      final state = cubit.state as RoadmapsLoaded;
      expect(state.active?.isPosition, isTrue);
      expect(state.positions.keys, ['backend']);
      await cubit.close();
    });

    test('position roadmaps survive storage round trip', () async {
      await AddPositionRoadmap(graph.roadmaps, graph.catalog)(
        'backend',
        'dart',
        QuestionLevel.junior,
      );
      final stored = graph.roadmapsLocal.read().roadmaps.single;
      expect(
        stored,
        isA<UserRoadmap>()
            .having((r) => r.positionId, 'positionId', 'backend')
            .having((r) => r.optionId, 'optionId', 'dart'),
      );
    });
  });
}
