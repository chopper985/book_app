// Project imports:
import 'package:interview_practice/core/helpers/app_clock.dart';
import 'package:interview_practice/core/utils/dio_api/result.dart';
import 'package:interview_practice/features/catalog/data/datasources/mock_dashboard_datasource.dart';
import 'package:interview_practice/features/catalog/data/repositories/catalog_repository_impl.dart';
import 'package:interview_practice/features/catalog/data/repositories/saved_tracks_repository_impl.dart';
import 'package:interview_practice/features/catalog/data/repositories/user_roadmaps_repository_impl.dart';
import 'package:interview_practice/features/content/data/parsers/content_parser.dart';
import 'package:interview_practice/features/content/domain/entities/content_catalog.dart';
import 'package:interview_practice/features/content/domain/repositories/content_repository.dart';
import 'package:interview_practice/features/practice/data/repositories/practice_repository_impl.dart';
import 'package:interview_practice/features/profile/data/repositories/profile_repository_impl.dart';
import 'package:interview_practice/features/sync/domain/usecase/learner_sync.dart';
import '../features/content/content_test_data.dart';
import 'fake_auth_repository.dart';
import 'in_memory_avatar_datasource.dart';
import 'in_memory_cloud_sync_repository.dart';
import 'in_memory_practice_datasource.dart';
import 'in_memory_profile_datasource.dart';
import 'in_memory_saved_tracks_datasource.dart';
import 'in_memory_user_roadmaps_datasource.dart';

class FakeContentRepository implements ContentRepository {
  final ContentCatalog catalog;

  FakeContentRepository(this.catalog);

  @override
  Future<Result<ContentCatalog>> loadCatalog() async => Result.success(catalog);
}

class FixedClock extends AppClock {
  DateTime value;

  FixedClock([DateTime? value]) : value = value ?? DateTime(2026, 11, 20, 9);

  @override
  DateTime now() => value;
}

/// Every repository wired with in-memory storage, like the app's DI graph.
class TestGraph {
  final FixedClock clock;
  final FakeContentRepository content;
  final InMemoryPracticeLocalDataSource practiceLocal =
      InMemoryPracticeLocalDataSource();
  final InMemoryProfileLocalDataSource profileLocal =
      InMemoryProfileLocalDataSource();
  final InMemorySavedTracksLocalDataSource savedLocal =
      InMemorySavedTracksLocalDataSource();
  final InMemoryUserRoadmapsLocalDataSource roadmapsLocal =
      InMemoryUserRoadmapsLocalDataSource();

  late final PracticeRepositoryImpl practice =
      PracticeRepositoryImpl(content, practiceLocal, clock);
  late final ProfileRepositoryImpl profiles = ProfileRepositoryImpl(
    profileLocal,
    InMemoryAvatarLocalDataSource(),
    clock,
  );
  late final SavedTracksRepositoryImpl saved =
      SavedTracksRepositoryImpl(savedLocal);
  late final UserRoadmapsRepositoryImpl roadmaps =
      UserRoadmapsRepositoryImpl(roadmapsLocal, clock);
  late final CatalogRepositoryImpl catalog = CatalogRepositoryImpl(
    content,
    practice,
    profiles,
    saved,
    roadmaps,
    MockDashboardDataSource(),
    clock,
  );

  final FakeAuthRepository auth = FakeAuthRepository();
  final InMemoryCloudSyncRepository cloud = InMemoryCloudSyncRepository();
  late final LearnerSync sync =
      LearnerSync(auth, cloud, practice, profiles, saved, roadmaps);

  TestGraph._(this.content, this.clock);

  /// [data] defaults to the minimal valid content of `content_test_data`.
  static Future<TestGraph> create({Map<String, String>? data}) async {
    final parsed = await const ContentParser().parse(readerOf(data ?? files()));
    // Same as ContentRepositoryImpl: topic sets generated after parsing.
    return TestGraph._(
      FakeContentRepository(parsed.catalog.withTopicSets()),
      FixedClock(),
    );
  }
}
