// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:i18n_extension/i18n_extension.dart';
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
import 'package:interview_practice/features/content/domain/repositories/content_repository.dart';
import 'package:interview_practice/features/practice/data/repositories/practice_repository_impl.dart';
import 'package:interview_practice/features/profile/data/repositories/profile_repository_impl.dart';
import 'package:interview_practice/features/profile/domain/entities/learner_profile.dart';
import 'package:interview_practice/features/profile/domain/usecase/profile_usecases.dart';
import 'package:interview_practice/features/profile/presentation/cubit/onboarding_cubit.dart';
import 'package:interview_practice/features/profile/presentation/extensions/profile_labels.dart';
import 'package:interview_practice/features/profile/presentation/screens/onboarding_screen.dart';
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

void main() {
  late OnboardingCubit cubit;

  Future<void> pump(WidgetTester tester, {double textScale = 1}) async {
    await tester.runAsync(() async {
      final content = _FakeContentRepository(
        (await const ContentParser().parse(readerOf(files()))).catalog,
      );
      final clock = AppClock();
      final profiles = ProfileRepositoryImpl(
        InMemoryProfileLocalDataSource(),
        InMemoryAvatarLocalDataSource(),
        clock,
      );
      final catalog = CatalogRepositoryImpl(
        content,
        PracticeRepositoryImpl(
          content,
          InMemoryPracticeLocalDataSource(),
          clock,
        ),
        profiles,
        SavedTracksRepositoryImpl(InMemorySavedTracksLocalDataSource()),
        UserRoadmapsRepositoryImpl(          InMemoryUserRoadmapsLocalDataSource(),          AppClock(),        ),
        MockDashboardDataSource(),
        clock,
      );
      cubit = OnboardingCubit(
        GetTracks(catalog),
        SaveProfile(profiles),
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
            builder: (context, child) => MediaQuery(
              data: MediaQuery.of(context).copyWith(
                textScaler: TextScaler.linear(textScale),
              ),
              child: child!,
            ),
            home: BlocProvider.value(
              value: cubit,
              child: const OnboardingScreen(),
            ),
          ),
        ),
      ),
    );
    await tester.pump();
  }

  testWidgets('walks every step on a small screen at 1.3x text',
      (tester) async {
    await pump(tester, textScale: 1.3);
    expect(find.text(Strings.onboardingNameTitle.i18n), findsOneWidget);
    expect(tester.takeException(), isNull);

    await tester.enterText(find.byType(TextField), 'Lan');
    await tester.pump();
    await tester.tap(find.text(Strings.onboardingNext.i18n));
    await tester.pumpAndSettle();

    await tester.tap(find.text(TargetRole.fullstack.label));
    await tester.pump();
    await tester.tap(find.text(Strings.onboardingNext.i18n));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);

    await tester.tap(find.text(ExperienceLevel.student.label));
    await tester.pump();
    await tester.tap(find.text(Strings.onboardingNext.i18n));
    await tester.pumpAndSettle();

    expect(find.text(Strings.onboardingFinish.i18n), findsOneWidget);
    expect(find.text('Go Backend'), findsOneWidget);
    expect(tester.takeException(), isNull);

    await tester.tap(find.text('Dart'));
    await tester.pump();
    expect(cubit.state.techStack, ['dart']);
    expect(cubit.state.canContinue, isTrue);

    await tester.pumpWidget(const SizedBox());
    await tester.runAsync(cubit.close);
  });
}
