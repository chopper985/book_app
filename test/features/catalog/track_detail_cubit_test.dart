// Package imports:
import 'package:flutter_test/flutter_test.dart';

// Project imports:
import 'package:AppName/core/utils/dio_api/result.dart';
import 'package:AppName/features/catalog/data/datasources/mock_dashboard_datasource.dart';
import 'package:AppName/features/catalog/data/repositories/catalog_repository_impl.dart';
import 'package:AppName/features/catalog/domain/usecase/get_track_detail.dart';
import 'package:AppName/features/catalog/presentation/cubit/track_detail_cubit.dart';
import 'package:AppName/features/content/data/parsers/content_parser.dart';
import 'package:AppName/features/content/domain/entities/content_catalog.dart';
import 'package:AppName/features/content/domain/entities/content_failure.dart';
import 'package:AppName/features/content/domain/entities/content_issue.dart';
import 'package:AppName/features/content/domain/entities/question.dart';
import 'package:AppName/features/content/domain/repositories/content_repository.dart';
import '../content/content_test_data.dart';

class _FakeContentRepository implements ContentRepository {
  final Result<ContentCatalog> result;

  _FakeContentRepository(this.result);

  @override
  Future<Result<ContentCatalog>> loadCatalog() async => result;
}

Future<TrackDetailCubit> cubitWith(Result<ContentCatalog> result) async {
  final repository = CatalogRepositoryImpl(
    _FakeContentRepository(result),
    MockDashboardDataSource(),
  );
  return TrackDetailCubit(GetTrackDetail(repository));
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
