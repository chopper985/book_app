// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format width=80

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:get_it/get_it.dart' as _i174;
import 'package:injectable/injectable.dart' as _i526;

import '../../features/auth/presentation/cubit/auth_cubit.dart' as _i117;
import '../../features/catalog/data/datasources/mock_dashboard_datasource.dart'
    as _i641;
import '../../features/catalog/data/repositories/catalog_repository_impl.dart'
    as _i428;
import '../../features/catalog/domain/repositories/catalog_repository.dart'
    as _i1018;
import '../../features/catalog/domain/usecase/get_explore_data.dart' as _i4;
import '../../features/catalog/domain/usecase/get_track_detail.dart' as _i875;
import '../../features/catalog/presentation/cubit/explore_cubit.dart' as _i978;
import '../../features/catalog/presentation/cubit/track_detail_cubit.dart'
    as _i805;
import '../../features/content/data/datasources/content_asset_datasource.dart'
    as _i915;
import '../../features/content/data/repositories/content_repository_impl.dart'
    as _i463;
import '../../features/content/domain/repositories/content_repository.dart'
    as _i1027;
import '../../features/content/domain/usecase/load_catalog.dart' as _i750;
import '../../features/practice/data/datasources/practice_local_datasource.dart'
    as _i264;
import '../../features/practice/data/repositories/practice_repository_impl.dart'
    as _i862;
import '../../features/practice/domain/repositories/practice_repository.dart'
    as _i980;
import '../../features/practice/domain/usecase/practice_usecases.dart' as _i673;
import '../../features/practice/presentation/cubit/practice_cubit.dart'
    as _i411;
import '../../features/practice/presentation/cubit/result_cubit.dart' as _i36;
import '../../features/profile/data/datasources/profile_local_datasource.dart'
    as _i1046;
import '../../features/profile/data/repositories/profile_repository_impl.dart'
    as _i334;
import '../../features/profile/domain/repositories/profile_repository.dart'
    as _i894;
import '../../features/profile/domain/usecase/profile_usecases.dart' as _i852;
import '../../features/profile/presentation/cubit/onboarding_cubit.dart'
    as _i934;
import '../../features/theme/presentation/cubit/theme_cubit.dart' as _i5;
import '../helpers/app_clock.dart' as _i472;
import '../utils/datasources/base_repository.dart' as _i961;
import '../utils/dio_api/dio_configuration.dart' as _i721;

// initializes the registration of main-scope dependencies inside of GetIt
_i174.GetIt $initGetIt(
  _i174.GetIt getIt, {
  String? environment,
  _i526.EnvironmentFilter? environmentFilter,
}) {
  final gh = _i526.GetItHelper(
    getIt,
    environment,
    environmentFilter,
  );
  gh.factory<_i117.AuthCubit>(() => _i117.AuthCubit());
  gh.factory<_i5.ThemeCubit>(() => _i5.ThemeCubit());
  gh.lazySingleton<_i472.AppClock>(() => _i472.AppClock());
  gh.lazySingleton<_i721.DioConfiguration>(() => _i721.DioConfiguration());
  gh.lazySingleton<_i641.MockDashboardDataSource>(
      () => _i641.MockDashboardDataSource());
  gh.lazySingleton<_i915.ContentAssetDataSource>(
      () => _i915.ContentAssetDataSource());
  gh.lazySingleton<_i1027.ContentRepository>(
      () => _i463.ContentRepositoryImpl(gh<_i915.ContentAssetDataSource>()));
  gh.lazySingleton<_i264.PracticeLocalDataSource>(
      () => _i264.HivePracticeLocalDataSource());
  gh.lazySingleton<_i1046.ProfileLocalDataSource>(
      () => _i1046.HiveProfileLocalDataSource());
  gh.lazySingleton<_i961.BaseRepository>(
      () => _i961.BaseRepository(gh<_i721.DioConfiguration>()));
  gh.lazySingleton<_i980.PracticeRepository>(() => _i862.PracticeRepositoryImpl(
        gh<_i1027.ContentRepository>(),
        gh<_i264.PracticeLocalDataSource>(),
        gh<_i472.AppClock>(),
      ));
  gh.factory<_i750.LoadCatalog>(
      () => _i750.LoadCatalog(gh<_i1027.ContentRepository>()));
  gh.factory<_i673.StartPractice>(
      () => _i673.StartPractice(gh<_i980.PracticeRepository>()));
  gh.factory<_i673.ResumePractice>(
      () => _i673.ResumePractice(gh<_i980.PracticeRepository>()));
  gh.factory<_i673.SavePractice>(
      () => _i673.SavePractice(gh<_i980.PracticeRepository>()));
  gh.factory<_i673.SubmitPractice>(
      () => _i673.SubmitPractice(gh<_i980.PracticeRepository>()));
  gh.factory<_i673.GetPracticeResult>(
      () => _i673.GetPracticeResult(gh<_i980.PracticeRepository>()));
  gh.lazySingleton<_i894.ProfileRepository>(() => _i334.ProfileRepositoryImpl(
        gh<_i1046.ProfileLocalDataSource>(),
        gh<_i472.AppClock>(),
      ));
  gh.lazySingleton<_i1018.CatalogRepository>(() => _i428.CatalogRepositoryImpl(
        gh<_i1027.ContentRepository>(),
        gh<_i980.PracticeRepository>(),
        gh<_i894.ProfileRepository>(),
        gh<_i641.MockDashboardDataSource>(),
        gh<_i472.AppClock>(),
      ));
  gh.factory<_i36.ResultCubit>(
      () => _i36.ResultCubit(gh<_i673.GetPracticeResult>()));
  gh.factory<_i411.PracticeCubit>(() => _i411.PracticeCubit(
        gh<_i673.StartPractice>(),
        gh<_i673.ResumePractice>(),
        gh<_i673.SavePractice>(),
        gh<_i673.SubmitPractice>(),
      ));
  gh.factory<_i852.GetProfile>(
      () => _i852.GetProfile(gh<_i894.ProfileRepository>()));
  gh.factory<_i852.SaveProfile>(
      () => _i852.SaveProfile(gh<_i894.ProfileRepository>()));
  gh.factory<_i4.GetTracks>(
      () => _i4.GetTracks(gh<_i1018.CatalogRepository>()));
  gh.factory<_i4.GetExploreDashboard>(
      () => _i4.GetExploreDashboard(gh<_i1018.CatalogRepository>()));
  gh.factory<_i4.WatchProgress>(
      () => _i4.WatchProgress(gh<_i1018.CatalogRepository>()));
  gh.factory<_i875.GetTrackDetail>(
      () => _i875.GetTrackDetail(gh<_i1018.CatalogRepository>()));
  gh.factory<_i934.OnboardingCubit>(() => _i934.OnboardingCubit(
        gh<_i4.GetTracks>(),
        gh<_i852.SaveProfile>(),
      ));
  gh.factory<_i805.TrackDetailCubit>(() => _i805.TrackDetailCubit(
        gh<_i875.GetTrackDetail>(),
        gh<_i4.WatchProgress>(),
      ));
  gh.factory<_i978.ExploreCubit>(() => _i978.ExploreCubit(
        gh<_i4.GetTracks>(),
        gh<_i4.GetExploreDashboard>(),
        gh<_i4.WatchProgress>(),
      ));
  return getIt;
}
