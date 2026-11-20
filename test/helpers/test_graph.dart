// Project imports:
import 'package:AppName/core/helpers/app_clock.dart';
import 'package:AppName/core/utils/dio_api/result.dart';
import 'package:AppName/features/catalog/data/datasources/mock_dashboard_datasource.dart';
import 'package:AppName/features/catalog/data/repositories/catalog_repository_impl.dart';
import 'package:AppName/features/catalog/data/repositories/saved_tracks_repository_impl.dart';
import 'package:AppName/features/content/data/parsers/content_parser.dart';
import 'package:AppName/features/content/domain/entities/content_catalog.dart';
import 'package:AppName/features/content/domain/repositories/content_repository.dart';
import 'package:AppName/features/practice/data/repositories/practice_repository_impl.dart';
import 'package:AppName/features/profile/data/repositories/profile_repository_impl.dart';
import '../features/content/content_test_data.dart';
import 'in_memory_avatar_datasource.dart';
import 'in_memory_practice_datasource.dart';
import 'in_memory_profile_datasource.dart';
import 'in_memory_saved_tracks_datasource.dart';

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

  late final PracticeRepositoryImpl practice =
      PracticeRepositoryImpl(content, practiceLocal, clock);
  late final ProfileRepositoryImpl profiles = ProfileRepositoryImpl(
    profileLocal,
    InMemoryAvatarLocalDataSource(),
    clock,
  );
  late final SavedTracksRepositoryImpl saved =
      SavedTracksRepositoryImpl(savedLocal);
  late final CatalogRepositoryImpl catalog = CatalogRepositoryImpl(
    content,
    practice,
    profiles,
    saved,
    MockDashboardDataSource(),
    clock,
  );

  TestGraph._(this.content, this.clock);

  /// [data] defaults to the minimal valid content of `content_test_data`.
  static Future<TestGraph> create({Map<String, String>? data}) async {
    final parsed = await const ContentParser().parse(readerOf(data ?? files()));
    return TestGraph._(FakeContentRepository(parsed.catalog), FixedClock());
  }
}
