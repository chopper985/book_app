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

import '../../features/auth/data/repositories/auth_repository_impl.dart'
    as _i153;
import '../../features/auth/domain/repositories/auth_repository.dart' as _i787;
import '../../features/auth/domain/usecase/account_usecases.dart' as _i509;
import '../../features/auth/presentation/cubit/auth_cubit.dart' as _i117;
import '../../features/auth/presentation/cubit/sign_in_cubit.dart' as _i329;
import '../../features/catalog/data/datasources/mock_dashboard_datasource.dart'
    as _i641;
import '../../features/catalog/data/datasources/saved_tracks_local_datasource.dart'
    as _i913;
import '../../features/catalog/data/datasources/user_roadmaps_local_datasource.dart'
    as _i1071;
import '../../features/catalog/data/repositories/catalog_repository_impl.dart'
    as _i428;
import '../../features/catalog/data/repositories/saved_tracks_repository_impl.dart'
    as _i534;
import '../../features/catalog/data/repositories/user_roadmaps_repository_impl.dart'
    as _i633;
import '../../features/catalog/domain/repositories/catalog_repository.dart'
    as _i1018;
import '../../features/catalog/domain/repositories/saved_tracks_repository.dart'
    as _i452;
import '../../features/catalog/domain/repositories/user_roadmaps_repository.dart'
    as _i409;
import '../../features/catalog/domain/usecase/get_explore_data.dart' as _i4;
import '../../features/catalog/domain/usecase/get_track_detail.dart' as _i875;
import '../../features/catalog/domain/usecase/saved_tracks.dart' as _i385;
import '../../features/catalog/domain/usecase/user_roadmaps.dart' as _i301;
import '../../features/catalog/presentation/cubit/explore_cubit.dart' as _i979;
import '../../features/catalog/presentation/cubit/position_detail_cubit.dart'
    as _i1012;
import '../../features/catalog/presentation/cubit/roadmap_picker_cubit.dart'
    as _i966;
import '../../features/catalog/presentation/cubit/roadmaps_cubit.dart' as _i152;
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
import '../../features/practice/domain/usecase/find_completed_result.dart'
    as _i414;
import '../../features/practice/domain/usecase/get_practice_hub.dart' as _i1037;
import '../../features/practice/domain/usecase/practice_usecases.dart' as _i673;
import '../../features/practice/presentation/cubit/practice_cubit.dart'
    as _i411;
import '../../features/practice/presentation/cubit/practice_hub_cubit.dart'
    as _i269;
import '../../features/practice/presentation/cubit/result_cubit.dart' as _i36;
import '../../features/profile/data/datasources/avatar_local_datasource.dart'
    as _i544;
import '../../features/profile/data/datasources/profile_local_datasource.dart'
    as _i1046;
import '../../features/profile/data/repositories/profile_repository_impl.dart'
    as _i334;
import '../../features/profile/domain/repositories/profile_repository.dart'
    as _i894;
import '../../features/profile/domain/usecase/profile_usecases.dart' as _i852;
import '../../features/profile/presentation/cubit/edit_profile_cubit.dart'
    as _i990;
import '../../features/profile/presentation/cubit/onboarding_cubit.dart'
    as _i934;
import '../../features/profile/presentation/cubit/profile_cubit.dart' as _i37;
import '../../features/sync/data/repositories/firestore_sync_repository.dart'
    as _i978;
import '../../features/sync/domain/repositories/cloud_sync_repository.dart'
    as _i576;
import '../../features/sync/domain/usecase/learner_sync.dart' as _i1036;
import '../../features/theme/presentation/cubit/theme_cubit.dart' as _i5;
import '../analytics/app_analytics.dart' as _i1033;
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
  gh.factory<_i5.ThemeCubit>(() => _i5.ThemeCubit());
  gh.lazySingleton<_i472.AppClock>(() => _i472.AppClock());
  gh.lazySingleton<_i721.DioConfiguration>(() => _i721.DioConfiguration());
  gh.lazySingleton<_i641.MockDashboardDataSource>(
      () => _i641.MockDashboardDataSource());
  gh.lazySingleton<_i915.ContentAssetDataSource>(
      () => _i915.ContentAssetDataSource());
  gh.lazySingleton<_i961.BaseRepository>(
      () => _i961.BaseRepository(gh<_i721.DioConfiguration>()));
  gh.lazySingleton<_i544.AvatarLocalDataSource>(
      () => _i544.FileAvatarLocalDataSource());
  gh.lazySingleton<_i787.AuthRepository>(() => _i153.AuthRepositoryImpl());
  gh.lazySingleton<_i264.PracticeLocalDataSource>(
      () => _i264.HivePracticeLocalDataSource());
  gh.lazySingleton<_i1033.AppAnalytics>(() => _i1033.FirebaseAppAnalytics());
  gh.lazySingleton<_i913.SavedTracksLocalDataSource>(
      () => _i913.HiveSavedTracksLocalDataSource());
  gh.lazySingleton<_i1046.ProfileLocalDataSource>(
      () => _i1046.HiveProfileLocalDataSource());
  gh.lazySingleton<_i576.CloudSyncRepository>(
      () => _i978.FirestoreSyncRepository());
  gh.lazySingleton<_i1071.UserRoadmapsLocalDataSource>(
      () => _i1071.HiveUserRoadmapsLocalDataSource());
  gh.lazySingleton<_i452.SavedTracksRepository>(() =>
      _i534.SavedTracksRepositoryImpl(gh<_i913.SavedTracksLocalDataSource>()));
  gh.lazySingleton<_i409.UserRoadmapsRepository>(
      () => _i633.UserRoadmapsRepositoryImpl(
            gh<_i1071.UserRoadmapsLocalDataSource>(),
            gh<_i472.AppClock>(),
          ));
  gh.lazySingleton<_i1027.ContentRepository>(
      () => _i463.ContentRepositoryImpl(gh<_i915.ContentAssetDataSource>()));
  gh.factory<_i385.GetSavedTrackIds>(
      () => _i385.GetSavedTrackIds(gh<_i452.SavedTracksRepository>()));
  gh.factory<_i385.ToggleSavedTrack>(
      () => _i385.ToggleSavedTrack(gh<_i452.SavedTracksRepository>()));
  gh.factory<_i301.GetUserRoadmaps>(
      () => _i301.GetUserRoadmaps(gh<_i409.UserRoadmapsRepository>()));
  gh.factory<_i301.AddUserRoadmap>(
      () => _i301.AddUserRoadmap(gh<_i409.UserRoadmapsRepository>()));
  gh.factory<_i301.SelectUserRoadmap>(
      () => _i301.SelectUserRoadmap(gh<_i409.UserRoadmapsRepository>()));
  gh.factory<_i301.RemoveUserRoadmap>(
      () => _i301.RemoveUserRoadmap(gh<_i409.UserRoadmapsRepository>()));
  gh.factory<_i509.WatchAuthUser>(
      () => _i509.WatchAuthUser(gh<_i787.AuthRepository>()));
  gh.factory<_i509.SignInWithGoogle>(
      () => _i509.SignInWithGoogle(gh<_i787.AuthRepository>()));
  gh.factory<_i509.SignInWithFacebook>(
      () => _i509.SignInWithFacebook(gh<_i787.AuthRepository>()));
  gh.factory<_i509.RequestPhoneCode>(
      () => _i509.RequestPhoneCode(gh<_i787.AuthRepository>()));
  gh.factory<_i509.ConfirmPhoneCode>(
      () => _i509.ConfirmPhoneCode(gh<_i787.AuthRepository>()));
  gh.lazySingleton<_i894.ProfileRepository>(() => _i334.ProfileRepositoryImpl(
        gh<_i1046.ProfileLocalDataSource>(),
        gh<_i544.AvatarLocalDataSource>(),
        gh<_i472.AppClock>(),
      ));
  gh.factory<_i750.LoadCatalog>(
      () => _i750.LoadCatalog(gh<_i1027.ContentRepository>()));
  gh.lazySingleton<_i980.PracticeRepository>(() => _i862.PracticeRepositoryImpl(
        gh<_i1027.ContentRepository>(),
        gh<_i264.PracticeLocalDataSource>(),
        gh<_i472.AppClock>(),
      ));
  gh.factory<_i329.SignInCubit>(() => _i329.SignInCubit(
        gh<_i509.SignInWithGoogle>(),
        gh<_i509.SignInWithFacebook>(),
        gh<_i509.RequestPhoneCode>(),
        gh<_i509.ConfirmPhoneCode>(),
      ));
  gh.factory<_i301.SuggestRoadmapLevel>(
      () => _i301.SuggestRoadmapLevel(gh<_i894.ProfileRepository>()));
  gh.lazySingleton<_i1018.CatalogRepository>(() => _i428.CatalogRepositoryImpl(
        gh<_i1027.ContentRepository>(),
        gh<_i980.PracticeRepository>(),
        gh<_i894.ProfileRepository>(),
        gh<_i452.SavedTracksRepository>(),
        gh<_i409.UserRoadmapsRepository>(),
        gh<_i641.MockDashboardDataSource>(),
        gh<_i472.AppClock>(),
      ));
  gh.factory<_i852.GetProfile>(
      () => _i852.GetProfile(gh<_i894.ProfileRepository>()));
  gh.factory<_i852.SaveProfile>(
      () => _i852.SaveProfile(gh<_i894.ProfileRepository>()));
  gh.factory<_i852.StoreAvatar>(
      () => _i852.StoreAvatar(gh<_i894.ProfileRepository>()));
  gh.factory<_i852.GetAvatarPath>(
      () => _i852.GetAvatarPath(gh<_i894.ProfileRepository>()));
  gh.lazySingleton<_i1036.LearnerSync>(() => _i1036.LearnerSync(
        gh<_i787.AuthRepository>(),
        gh<_i576.CloudSyncRepository>(),
        gh<_i980.PracticeRepository>(),
        gh<_i894.ProfileRepository>(),
        gh<_i452.SavedTracksRepository>(),
        gh<_i409.UserRoadmapsRepository>(),
      ));
  gh.factory<_i301.AddPositionRoadmap>(() => _i301.AddPositionRoadmap(
        gh<_i409.UserRoadmapsRepository>(),
        gh<_i1018.CatalogRepository>(),
      ));
  gh.factory<_i4.GetTracks>(
      () => _i4.GetTracks(gh<_i1018.CatalogRepository>()));
  gh.factory<_i4.GetExploreDashboard>(
      () => _i4.GetExploreDashboard(gh<_i1018.CatalogRepository>()));
  gh.factory<_i4.WatchProgress>(
      () => _i4.WatchProgress(gh<_i1018.CatalogRepository>()));
  gh.factory<_i875.GetTrackDetail>(
      () => _i875.GetTrackDetail(gh<_i1018.CatalogRepository>()));
  gh.factory<_i301.GetPositions>(
      () => _i301.GetPositions(gh<_i1018.CatalogRepository>()));
  gh.factory<_i301.GetPositionDetail>(
      () => _i301.GetPositionDetail(gh<_i1018.CatalogRepository>()));
  gh.factory<_i1037.GetPracticeHub>(() => _i1037.GetPracticeHub(
        gh<_i1027.ContentRepository>(),
        gh<_i980.PracticeRepository>(),
        gh<_i894.ProfileRepository>(),
      ));
  gh.factory<_i509.ClearLocalLearnerData>(() => _i509.ClearLocalLearnerData(
        gh<_i980.PracticeRepository>(),
        gh<_i894.ProfileRepository>(),
        gh<_i452.SavedTracksRepository>(),
        gh<_i409.UserRoadmapsRepository>(),
      ));
  gh.factory<_i301.OpenTrackRoadmap>(() => _i301.OpenTrackRoadmap(
        gh<_i409.UserRoadmapsRepository>(),
        gh<_i301.SuggestRoadmapLevel>(),
      ));
  gh.factory<_i934.OnboardingCubit>(() => _i934.OnboardingCubit(
        gh<_i4.GetTracks>(),
        gh<_i852.SaveProfile>(),
        analytics: gh<_i1033.AppAnalytics>(),
      ));
  gh.factory<_i673.StartPractice>(
      () => _i673.StartPractice(gh<_i980.PracticeRepository>()));
  gh.factory<_i673.ResumePractice>(
      () => _i673.ResumePractice(gh<_i980.PracticeRepository>()));
  gh.factory<_i673.ClearPracticeHistory>(
      () => _i673.ClearPracticeHistory(gh<_i980.PracticeRepository>()));
  gh.factory<_i673.SavePractice>(
      () => _i673.SavePractice(gh<_i980.PracticeRepository>()));
  gh.factory<_i673.SubmitPractice>(
      () => _i673.SubmitPractice(gh<_i980.PracticeRepository>()));
  gh.factory<_i673.GetPracticeResult>(
      () => _i673.GetPracticeResult(gh<_i980.PracticeRepository>()));
  gh.factory<_i414.FindCompletedResult>(() => _i414.FindCompletedResult(
        gh<_i1027.ContentRepository>(),
        gh<_i980.PracticeRepository>(),
      ));
  gh.factory<_i152.RoadmapsCubit>(() => _i152.RoadmapsCubit(
        gh<_i301.GetUserRoadmaps>(),
        gh<_i301.SelectUserRoadmap>(),
        gh<_i301.RemoveUserRoadmap>(),
        gh<_i4.GetTracks>(),
        gh<_i4.GetExploreDashboard>(),
        gh<_i301.GetPositions>(),
        gh<_i4.WatchProgress>(),
      ));
  gh.factory<_i509.SignOut>(() => _i509.SignOut(
        gh<_i787.AuthRepository>(),
        gh<_i1036.LearnerSync>(),
        gh<_i509.ClearLocalLearnerData>(),
      ));
  gh.factory<_i509.DeleteAccount>(() => _i509.DeleteAccount(
        gh<_i787.AuthRepository>(),
        gh<_i1036.LearnerSync>(),
        gh<_i509.ClearLocalLearnerData>(),
      ));
  gh.factory<_i117.AuthCubit>(() => _i117.AuthCubit(
        gh<_i509.WatchAuthUser>(),
        gh<_i509.SignOut>(),
        gh<_i509.DeleteAccount>(),
      ));
  gh.factory<_i990.EditProfileCubit>(() => _i990.EditProfileCubit(
        gh<_i852.GetProfile>(),
        gh<_i852.GetAvatarPath>(),
        gh<_i852.StoreAvatar>(),
        gh<_i852.SaveProfile>(),
        gh<_i4.GetTracks>(),
        analytics: gh<_i1033.AppAnalytics>(),
      ));
  gh.factory<_i966.RoadmapPickerCubit>(() => _i966.RoadmapPickerCubit(
        gh<_i4.GetTracks>(),
        gh<_i385.GetSavedTrackIds>(),
        gh<_i301.GetUserRoadmaps>(),
        gh<_i301.SuggestRoadmapLevel>(),
        gh<_i852.GetProfile>(),
        gh<_i301.AddUserRoadmap>(),
        gh<_i301.GetPositions>(),
        gh<_i301.AddPositionRoadmap>(),
      ));
  gh.factory<_i509.ResetProgressEverywhere>(() => _i509.ResetProgressEverywhere(
        gh<_i980.PracticeRepository>(),
        gh<_i1036.LearnerSync>(),
      ));
  gh.factory<_i269.PracticeHubCubit>(() => _i269.PracticeHubCubit(
        gh<_i1037.GetPracticeHub>(),
        gh<_i4.GetExploreDashboard>(),
        gh<_i4.WatchProgress>(),
      ));
  gh.factory<_i805.TrackDetailCubit>(() => _i805.TrackDetailCubit(
        gh<_i875.GetTrackDetail>(),
        gh<_i385.ToggleSavedTrack>(),
        gh<_i4.WatchProgress>(),
        analytics: gh<_i1033.AppAnalytics>(),
      ));
  gh.factory<_i1012.PositionDetailCubit>(() => _i1012.PositionDetailCubit(
        gh<_i301.GetPositionDetail>(),
        gh<_i4.WatchProgress>(),
      ));
  gh.factory<_i979.ExploreCubit>(() => _i979.ExploreCubit(
        gh<_i4.GetTracks>(),
        gh<_i4.GetExploreDashboard>(),
        gh<_i852.GetProfile>(),
        gh<_i301.OpenTrackRoadmap>(),
        gh<_i4.WatchProgress>(),
      ));
  gh.factory<_i36.ResultCubit>(
      () => _i36.ResultCubit(gh<_i673.GetPracticeResult>()));
  gh.factory<_i411.PracticeCubit>(() => _i411.PracticeCubit(
        gh<_i673.StartPractice>(),
        gh<_i673.ResumePractice>(),
        gh<_i673.SavePractice>(),
        gh<_i673.SubmitPractice>(),
        analytics: gh<_i1033.AppAnalytics>(),
      ));
  gh.factory<_i37.ProfileCubit>(() => _i37.ProfileCubit(
        gh<_i852.GetProfile>(),
        gh<_i852.GetAvatarPath>(),
        gh<_i4.GetExploreDashboard>(),
        gh<_i4.GetTracks>(),
        gh<_i509.ResetProgressEverywhere>(),
        gh<_i4.WatchProgress>(),
        analytics: gh<_i1033.AppAnalytics>(),
      ));
  return getIt;
}
