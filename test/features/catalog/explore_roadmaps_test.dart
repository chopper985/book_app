// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:i18n_extension/i18n_extension.dart' show I18n;
import 'package:sizer/sizer.dart';

// Project imports:
import 'package:AppName/core/app/languages/data/localization.dart';
import 'package:AppName/features/catalog/domain/usecase/filter_tracks.dart';
import 'package:AppName/features/catalog/domain/usecase/get_explore_data.dart';
import 'package:AppName/features/catalog/domain/usecase/get_track_detail.dart';
import 'package:AppName/features/catalog/domain/usecase/saved_tracks.dart';
import 'package:AppName/features/catalog/presentation/cubit/explore_cubit.dart';
import 'package:AppName/features/catalog/presentation/cubit/roadmaps_cubit.dart';
import 'package:AppName/features/catalog/presentation/cubit/track_detail_cubit.dart';
import 'package:AppName/features/catalog/presentation/screens/roadmaps_screen.dart';
import 'package:AppName/features/practice/domain/usecase/find_completed_result.dart';
import 'package:AppName/features/practice/domain/usecase/practice_usecases.dart';
import 'package:AppName/features/practice/presentation/cubit/practice_cubit.dart';
import 'package:AppName/features/profile/domain/entities/learner_profile.dart';
import 'package:AppName/features/profile/domain/usecase/profile_usecases.dart';
import '../../helpers/test_graph.dart';

void main() {
  late TestGraph graph;

  setUp(() async {
    graph = await TestGraph.create();
  });

  Future<void> saveProfile(List<String> stack) => graph.profiles.save(
        ProfileFields(
          displayName: 'Lan',
          role: TargetRole.mobile,
          experience: ExperienceLevel.junior,
          techStack: stack,
        ),
      );

  ExploreCubit newExplore() => ExploreCubit(
        GetTracks(graph.catalog),
        GetExploreDashboard(graph.catalog),
        GetProfile(graph.profiles),
        WatchProgress(graph.catalog),
      );

  RoadmapsCubit newRoadmaps() => RoadmapsCubit(
        GetTracks(graph.catalog),
        GetExploreDashboard(graph.catalog),
        GetSavedTrackIds(graph.saved),
        WatchProgress(graph.catalog),
      );

  group('Explore shows only the learner roadmaps', () {
    test('tracks of the stack, in pick order', () async {
      await saveProfile(['go', 'dart']);
      final cubit = newExplore();
      await cubit.load();
      final state = cubit.state as ExploreLoaded;
      expect(state.myTracks.map((t) => t.track.id), ['go', 'dart']);
      expect(state.tracks, hasLength(2), reason: 'all tracks kept for lookup');
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
  });

  group('Roadmaps library', () {
    test('search ignores case and diacritics, category filters', () async {
      final cubit = newRoadmaps();
      await cubit.load();
      RoadmapsLoaded state() => cubit.state as RoadmapsLoaded;
      expect(state().visibleTracks, hasLength(2));

      cubit.search('GO back');
      expect(state().visibleTracks.map((t) => t.track.id), ['go']);
      cubit.search('null safety');
      expect(
        state().visibleTracks.map((t) => t.track.id),
        ['dart'],
        reason: 'matches a topic name',
      );
      cubit.search('kotlin');
      expect(state().visibleTracks, isEmpty);
      expect(state().isFiltering, isTrue);
      cubit.search('');
      expect(state().isFiltering, isFalse);
      await cubit.close();
    });

    test('saved roadmaps follow the bookmark, filters survive refresh',
        () async {
      final roadmaps = newRoadmaps();
      await roadmaps.load();
      roadmaps.search('dart');

      final detail = TrackDetailCubit(
        GetTrackDetail(graph.catalog),
        ToggleSavedTrack(graph.saved),
        WatchProgress(graph.catalog),
      );
      await detail.load('dart');
      await detail.toggleSaved();
      await Future<void>.delayed(Duration.zero);

      var state = roadmaps.state as RoadmapsLoaded;
      expect(state.savedTracks.map((t) => t.track.id), ['dart']);
      expect(state.query, 'dart', reason: 'kept after the refresh');
      expect(state.visibleTracks.map((t) => t.track.id), ['dart']);
      expect(
        (detail.state as TrackDetailLoaded).detail.learning.isSaved,
        isTrue,
      );

      await detail.toggleSaved();
      await Future<void>.delayed(Duration.zero);
      state = roadmaps.state as RoadmapsLoaded;
      expect(state.savedTracks, isEmpty);
      await detail.close();
      await roadmaps.close();
    });
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

  testWidgets('roadmaps tab renders search and saved on a small screen',
      (tester) async {
    late RoadmapsCubit cubit;
    await tester.runAsync(() async {
      await graph.saved.toggle('dart');
      cubit = newRoadmaps();
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
              child: const RoadmapsScreen(),
            ),
          ),
        ),
      ),
    );
    await tester.pump();
    expect(tester.takeException(), isNull);
    expect(find.text(Strings.roadmapsSaved.i18n), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'zzz');
    await tester.pump();
    expect(find.text(Strings.roadmapsNoResult.i18n), findsOneWidget);
    expect(
      find.text(Strings.roadmapsSaved.i18n),
      findsNothing,
      reason: 'saved section hidden while searching',
    );

    await tester.pumpWidget(const SizedBox());
    await tester.runAsync(cubit.close);
  });
}
