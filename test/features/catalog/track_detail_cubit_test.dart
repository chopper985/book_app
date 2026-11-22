// Package imports:
import 'package:flutter_test/flutter_test.dart';

// Project imports:
import 'package:interview_practice/core/helpers/app_clock.dart';
import 'package:interview_practice/core/utils/dio_api/result.dart';
import 'package:interview_practice/features/catalog/data/datasources/mock_dashboard_datasource.dart';
import 'package:interview_practice/features/catalog/data/repositories/catalog_repository_impl.dart';
import 'package:interview_practice/features/catalog/data/repositories/saved_tracks_repository_impl.dart';
import 'package:interview_practice/features/catalog/data/repositories/user_roadmaps_repository_impl.dart';
import 'package:interview_practice/features/catalog/domain/usecase/get_explore_data.dart';
import 'package:interview_practice/features/catalog/domain/usecase/get_track_detail.dart';
import 'package:interview_practice/features/catalog/domain/usecase/saved_tracks.dart';
import 'package:interview_practice/features/catalog/presentation/cubit/track_detail_cubit.dart';
import 'package:interview_practice/features/content/data/parsers/content_parser.dart';
import 'package:interview_practice/features/content/domain/entities/content_catalog.dart';
import 'package:interview_practice/features/content/domain/entities/content_failure.dart';
import 'package:interview_practice/features/content/domain/entities/content_issue.dart';
import 'package:interview_practice/features/content/domain/entities/question.dart';
import 'package:interview_practice/features/content/domain/repositories/content_repository.dart';
import 'package:interview_practice/features/practice/data/repositories/practice_repository_impl.dart';
import 'package:interview_practice/features/profile/data/repositories/profile_repository_impl.dart';
import '../../helpers/in_memory_avatar_datasource.dart';
import '../../helpers/in_memory_practice_datasource.dart';
import '../../helpers/in_memory_profile_datasource.dart';
import '../../helpers/in_memory_saved_tracks_datasource.dart';
import '../../helpers/in_memory_user_roadmaps_datasource.dart';
import '../content/content_test_data.dart';

class _FakeContentRepository implements ContentRepository {
  final Result<ContentCatalog> result;

  _FakeContentRepository(this.result);

  @override
  Future<Result<ContentCatalog>> loadCatalog() async => result;
}

Future<TrackDetailCubit> cubitWith(Result<ContentCatalog> result) async {
  final content = _FakeContentRepository(result);
  final clock = AppClock();
  final saved = SavedTracksRepositoryImpl(InMemorySavedTracksLocalDataSource());
  final repository = CatalogRepositoryImpl(
    content,
    PracticeRepositoryImpl(content, InMemoryPracticeLocalDataSource(), clock),
    ProfileRepositoryImpl(
      InMemoryProfileLocalDataSource(),
      InMemoryAvatarLocalDataSource(),
      clock,
    ),
    saved,
    UserRoadmapsRepositoryImpl(
      InMemoryUserRoadmapsLocalDataSource(),
      AppClock(),
    ),
    MockDashboardDataSource(),
    clock,
  );
  return TrackDetailCubit(
    GetTrackDetail(repository),
    ToggleSavedTrack(saved),
    WatchProgress(repository),
  );
}

void main() {
  late ContentCatalog catalog;

  setUp(() async {
    final data = files(
      sets: [
        set(id: 'dart.fresher', questionIds: ['dart.q1']),
        set(id: 'dart.junior', questionIds: ['dart.q2']),
      ],
    );
    catalog = (await const ContentParser().parse(readerOf(data))).catalog;
  });

  test('loads the track and filters sets by level', () async {
    final cubit = await cubitWith(Result.success(catalog));
    await cubit.load('dart');

    var state = cubit.state as TrackDetailLoaded;
    expect(state.visibleSets.map((s) => s.set.id), [
      'dart.fresher',
      'dart.junior',
    ]);

    cubit.selectLevel(QuestionLevel.junior);
    state = cubit.state as TrackDetailLoaded;
    expect(state.visibleSets.map((s) => s.set.id), ['dart.junior']);

    cubit.selectTopic('null_safety');
    state = cubit.state as TrackDetailLoaded;
    expect(state.level, QuestionLevel.junior);
    expect(state.visibleSets.map((s) => s.set.id), ['dart.junior']);

    cubit.selectLevel(null);
    state = cubit.state as TrackDetailLoaded;
    expect(state.visibleSets, hasLength(2));
  });

  test('unavailable or unknown track is not found', () async {
    final cubit = await cubitWith(Result.success(catalog));
    await cubit.load('go');
    expect(cubit.state, isA<TrackDetailNotFound>());
  });

  test('invalid content surfaces the issues', () async {
    const issue = ContentIssue(
      code: ContentIssueCode.missingFile,
      path: 'dart/sets.json',
    );
    final cubit = await cubitWith(Result.failure(ContentFailure([issue])));
    await cubit.load('dart');
    expect(
      cubit.state,
      const TrackDetailInvalidContent([issue]),
    );
  });
}
