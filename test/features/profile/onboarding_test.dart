// Package imports:
import 'package:flutter_test/flutter_test.dart';

// Project imports:
import 'package:AppName/core/helpers/app_clock.dart';
import 'package:AppName/core/utils/dio_api/result.dart';
import 'package:AppName/features/catalog/data/datasources/mock_dashboard_datasource.dart';
import 'package:AppName/features/catalog/data/repositories/catalog_repository_impl.dart';
import 'package:AppName/features/catalog/data/repositories/saved_tracks_repository_impl.dart';
import 'package:AppName/features/catalog/data/repositories/user_roadmaps_repository_impl.dart';
import 'package:AppName/features/catalog/domain/usecase/get_explore_data.dart';
import 'package:AppName/features/content/data/parsers/content_parser.dart';
import 'package:AppName/features/content/domain/entities/content_catalog.dart';
import 'package:AppName/features/content/domain/repositories/content_repository.dart';
import 'package:AppName/features/practice/data/repositories/practice_repository_impl.dart';
import 'package:AppName/features/profile/data/repositories/profile_repository_impl.dart';
import 'package:AppName/features/profile/domain/entities/learner_profile.dart';
import 'package:AppName/features/profile/domain/usecase/profile_usecases.dart';
import 'package:AppName/features/profile/presentation/cubit/onboarding_cubit.dart';
import '../../helpers/in_memory_avatar_datasource.dart';
import '../../helpers/in_memory_practice_datasource.dart';
import '../../helpers/in_memory_saved_tracks_datasource.dart';
import '../../helpers/in_memory_user_roadmaps_datasource.dart';
import '../../helpers/in_memory_profile_datasource.dart';
import '../content/content_test_data.dart';

class _FakeContentRepository implements ContentRepository {
  final ContentCatalog catalog;

  _FakeContentRepository(this.catalog);

  @override
  Future<Result<ContentCatalog>> loadCatalog() async => Result.success(catalog);
}

class _FixedClock extends AppClock {
  DateTime value = DateTime(2026, 11, 20, 9);

  @override
  DateTime now() => value;
}

void main() {
  late _FixedClock clock;
  late InMemoryProfileLocalDataSource profileLocal;
  late ProfileRepositoryImpl profiles;
  late CatalogRepositoryImpl catalog;

  setUp(() async {
    final content = _FakeContentRepository(
      (await const ContentParser().parse(readerOf(files()))).catalog,
    );
    clock = _FixedClock();
    profileLocal = InMemoryProfileLocalDataSource();
    profiles = ProfileRepositoryImpl(
      profileLocal,
      InMemoryAvatarLocalDataSource(),
      clock,
    );
    catalog = CatalogRepositoryImpl(
      content,
      PracticeRepositoryImpl(content, InMemoryPracticeLocalDataSource(), clock),
      profiles,
      SavedTracksRepositoryImpl(InMemorySavedTracksLocalDataSource()),
      UserRoadmapsRepositoryImpl(        InMemoryUserRoadmapsLocalDataSource(),        AppClock(),      ),
      MockDashboardDataSource(),
      clock,
    );
  });

  OnboardingCubit newCubit() => OnboardingCubit(
        GetTracks(catalog),
        SaveProfile(profiles),
      );

  test('each step needs an answer before continuing', () async {
    final cubit = newCubit();
    await cubit.load();
    expect(cubit.state.tracks.map((t) => t.track.id), ['dart', 'go']);

    await cubit.next();
    expect(cubit.state.step, OnboardingStep.name, reason: 'empty name');
    cubit.setName('   ');
    expect(cubit.state.canContinue, isFalse);
    cubit.setName('Lan');
    await cubit.next();
    expect(cubit.state.step, OnboardingStep.role);

    await cubit.next();
    expect(cubit.state.step, OnboardingStep.role, reason: 'no role yet');
    cubit.selectRole(TargetRole.backend);
    await cubit.next();
    cubit.selectExperience(ExperienceLevel.fresher);
    await cubit.next();
    expect(cubit.state.step, OnboardingStep.stack);
    expect(cubit.state.isLastStep, isTrue);

    await cubit.next();
    expect(cubit.state.done, isFalse, reason: 'needs one track');
    cubit.toggleTrack('go');
    cubit.toggleTrack('dart');
    cubit.toggleTrack('go');
    expect(cubit.state.techStack, ['dart']);

    cubit.back();
    expect(cubit.state.step, OnboardingStep.experience);
    expect(cubit.state.experience, ExperienceLevel.fresher, reason: 'kept');
  });

  test('finishing saves a trimmed profile that survives a restart', () async {
    expect(profiles.hasProfile, isFalse);
    final cubit = newCubit();
    cubit.setName('  Lan  ');
    await cubit.next();
    cubit.selectRole(TargetRole.mobile);
    await cubit.next();
    cubit.selectExperience(ExperienceLevel.junior);
    await cubit.next();
    cubit.toggleTrack('go');
    cubit.setInterviewDate(DateTime(2026, 11, 27));
    await cubit.next();

    expect(cubit.state.done, isTrue);
    final restarted = ProfileRepositoryImpl(
      profileLocal,
      InMemoryAvatarLocalDataSource(),
      clock,
    );
    expect(
      restarted.profile,
      LearnerProfile(
        fields: ProfileFields(
          displayName: 'Lan',
          role: TargetRole.mobile,
          experience: ExperienceLevel.junior,
          techStack: const ['go'],
          interviewDate: DateTime(2026, 11, 27),
        ),
        createdAt: clock.value,
        updatedAt: clock.value,
      ),
    );
  });

  test('saving again keeps createdAt and notifies listeners', () async {
    await profiles.save(
      ProfileFields(
        displayName: 'Lan',
        role: TargetRole.mobile,
        experience: ExperienceLevel.junior,
        techStack: const ['dart'],
      ),
    );
    final created = clock.value;
    clock.value = clock.value.add(const Duration(days: 1));

    var changes = 0;
    final subscription = profiles.changes.listen((_) => changes++);
    final updated = await profiles.save(
      ProfileFields(
        displayName: 'Lan Anh',
        role: TargetRole.mobile,
        experience: ExperienceLevel.middle,
        techStack: const ['dart'],
      ),
    );
    await Future<void>.delayed(Duration.zero);
    await subscription.cancel();

    expect(updated.createdAt, created);
    expect(updated.updatedAt, clock.value);
    expect(changes, 1);
  });

  test('the name is capped at the maximum length', () {
    final cubit = newCubit();
    cubit.setName('a' * 40);
    expect(cubit.state.name.length, LearnerProfile.maxNameLength);
  });

  group('catalog uses the profile', () {
    test('learner name, experience and interview countdown', () async {
      await profiles.save(
        ProfileFields(
          displayName: 'Lan',
          role: TargetRole.backend,
          experience: ExperienceLevel.fresher,
          techStack: const ['go'],
          interviewDate: DateTime(2026, 11, 23),
        ),
      );
      final learner = (await catalog.getDashboard()).learner;
      expect(learner.displayName, 'Lan');
      expect(learner.experience, ExperienceLevel.fresher);
      expect(learner.daysToInterview, 3);
    });

    test('tracks of the stack come first', () async {
      var tracks = (await catalog.getTracks()).value!;
      expect(tracks.map((t) => t.track.id), ['dart', 'go']);

      await profiles.save(
        ProfileFields(
          displayName: 'Lan',
          role: TargetRole.backend,
          experience: ExperienceLevel.fresher,
          techStack: const ['go'],
        ),
      );
      tracks = (await catalog.getTracks()).value!;
      expect(tracks.map((t) => t.track.id), ['go', 'dart']);
    });

    test('progress changes include profile saves', () async {
      var changes = 0;
      final subscription = catalog.progressChanges.listen((_) => changes++);
      await profiles.save(
        ProfileFields(
          displayName: 'Lan',
          role: TargetRole.backend,
          experience: ExperienceLevel.fresher,
          techStack: const ['go'],
        ),
      );
      await Future<void>.delayed(Duration.zero);
      await subscription.cancel();
      expect(changes, 1);
    });
  });

  test('interview countdown is null once the day has passed', () {
    final profile = LearnerProfile(
      fields: ProfileFields(
        displayName: 'Lan',
        role: TargetRole.mobile,
        experience: ExperienceLevel.junior,
        techStack: const [],
        interviewDate: DateTime(2026, 11, 20),
      ),
      createdAt: DateTime(2026, 11, 2),
      updatedAt: DateTime(2026, 11, 2),
    );
    expect(profile.daysToInterview(DateTime(2026, 11, 20, 23)), 0);
    expect(profile.daysToInterview(DateTime(2026, 11, 21, 1)), isNull);
  });
}
