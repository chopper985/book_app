// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:sizer/sizer.dart';

// Project imports:
import 'package:AppName/core/analytics/app_analytics.dart';
import 'package:AppName/core/app/colors/app_colors.dart';
import 'package:AppName/core/injection/injection_container.dart';
import 'package:AppName/core/navigator/app_routes.dart';
import 'package:AppName/core/navigator/main_shell.dart';
import 'package:AppName/features/catalog/presentation/cubit/explore_cubit.dart';
import 'package:AppName/features/catalog/presentation/cubit/roadmaps_cubit.dart';
import 'package:AppName/features/catalog/presentation/cubit/track_detail_cubit.dart';
import 'package:AppName/features/catalog/presentation/screens/explore_screen.dart';
import 'package:AppName/features/catalog/presentation/screens/roadmaps_screen.dart';
import 'package:AppName/features/catalog/presentation/screens/track_detail_screen.dart';
import 'package:AppName/features/practice/presentation/cubit/practice_cubit.dart';
import 'package:AppName/features/practice/presentation/cubit/practice_hub_cubit.dart';
import 'package:AppName/features/practice/presentation/cubit/result_cubit.dart';
import 'package:AppName/features/practice/presentation/screens/practice_hub_screen.dart';
import 'package:AppName/features/practice/presentation/screens/practice_screen.dart';
import 'package:AppName/features/practice/presentation/screens/result_screen.dart';
import 'package:AppName/features/profile/domain/repositories/profile_repository.dart';
import 'package:AppName/features/profile/presentation/cubit/edit_profile_cubit.dart';
import 'package:AppName/features/profile/presentation/cubit/onboarding_cubit.dart';
import 'package:AppName/features/profile/presentation/cubit/profile_cubit.dart';
import 'package:AppName/features/profile/presentation/screens/edit_profile_screen.dart';
import 'package:AppName/features/profile/presentation/screens/onboarding_screen.dart';
import 'package:AppName/features/profile/presentation/screens/profile_screen.dart';

part 'app_router.g.dart';

class AppRouter {
  static final GlobalKey<NavigatorState> _rootNavigatorKey =
      GlobalKey<NavigatorState>(debugLabel: "_rootNavigatorKey");

  late final GoRouter router;
  static final AppRouter instance = AppRouter._internal();

  bool isLoadingShown = false;

  AppRouter._internal() {
    router = GoRouter(
      routes: $appRoutes,
      navigatorKey: _rootNavigatorKey,
      initialLocation: Routes.rootRoute,
      redirect: _requireProfile,
    );
    router.routerDelegate.addListener(_logScreen);
  }

  /// Logs the route template (e.g. `/roadmaps/:trackId`), never ids, on every
  /// navigation including tab switches.
  void _logScreen() {
    final path = router.routerDelegate.currentConfiguration.fullPath;
    if (path.isNotEmpty) getIt<AppAnalytics>().screenView(path);
  }

  /// Sends a learner without a profile to onboarding, and away from it once
  /// the profile exists.
  static String? _requireProfile(BuildContext context, GoRouterState state) {
    final hasProfile = getIt<ProfileRepository>().hasProfile;
    final onOnboarding = state.matchedLocation == Routes.onboardingRoute;
    if (!hasProfile && !onOnboarding) return Routes.onboardingRoute;
    if (hasProfile && onOnboarding) return Routes.rootRoute;
    return null;
  }

  void pop() {
    if (!canPop) return;

    if (isLoadingShown) {
      isLoadingShown = false;
    }

    router.pop();
  }

  bool get canPop => state.canPop();

  String get currentRoute => router.state.matchedLocation;

  static BuildContext? get context => _rootNavigatorKey.currentContext;

  static NavigatorState get state => _rootNavigatorKey.currentState!;

  void popLoading() {
    if (_rootNavigatorKey.currentState == null) return;

    if (!canPop || !isLoadingShown) {
      return;
    }

    isLoadingShown = false;
    _rootNavigatorKey.currentState?.pop();
  }

  void showLoading({String? title}) {
    if (isLoadingShown) {
      return;
    }

    isLoadingShown = true;

    try {
      Navigator.of(context!, rootNavigator: true).push(
        PageRouteBuilder(
          opaque: false,
          barrierColor: Colors.black26,
          pageBuilder: (context, _, __) {
            return PopScope(canPop: false, child: CircleLoading(title: title));
          },
          transitionDuration: Duration.zero,
        ),
      );
    } catch (e) {
      isLoadingShown = false;
    }
  }
}

@TypedGoRoute<OnboardingRoute>(
  path: Routes.onboardingRoute,
  name: Routes.onboardingRoute,
)
class OnboardingRoute extends GoRouteData with $OnboardingRoute {
  const OnboardingRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return BlocProvider(
      create: (_) => getIt<OnboardingCubit>()..load(),
      child: const OnboardingScreen(),
    );
  }
}

/// Full-screen profile edit: avatar, personal details, interview info.
@TypedGoRoute<EditProfileRoute>(
  path: Routes.editProfileRoute,
  name: Routes.editProfileRoute,
)
class EditProfileRoute extends GoRouteData with $EditProfileRoute {
  const EditProfileRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return BlocProvider(
      create: (_) => getIt<EditProfileCubit>()..load(),
      child: const EditProfileScreen(),
    );
  }
}

@TypedStatefulShellRoute<MainShellRoute>(
  branches: [
    TypedStatefulShellBranch<ExploreBranch>(
      routes: [
        TypedGoRoute<RootRoute>(path: Routes.rootRoute, name: Routes.rootRoute),
      ],
    ),
    TypedStatefulShellBranch<RoadmapsBranch>(
      routes: [
        TypedGoRoute<RoadmapsRoute>(
          path: Routes.roadmapsRoute,
          name: Routes.roadmapsRoute,
          routes: [
            TypedGoRoute<TrackDetailRoute>(
              path: Routes.trackDetailRoute,
              name: Routes.trackDetailRoute,
            ),
          ],
        ),
      ],
    ),
    TypedStatefulShellBranch<PracticeHubBranch>(
      routes: [
        TypedGoRoute<PracticeHubRoute>(
          path: Routes.practiceHubRoute,
          name: Routes.practiceHubRoute,
        ),
      ],
    ),
    TypedStatefulShellBranch<ProfileBranch>(
      routes: [
        TypedGoRoute<ProfileRoute>(
          path: Routes.profileRoute,
          name: Routes.profileRoute,
        ),
      ],
    ),
  ],
)
class MainShellRoute extends StatefulShellRouteData {
  const MainShellRoute();

  @override
  Widget builder(
    BuildContext context,
    GoRouterState state,
    StatefulNavigationShell navigationShell,
  ) {
    return MainShell(navigationShell: navigationShell);
  }
}

class ExploreBranch extends StatefulShellBranchData {
  const ExploreBranch();
}

class RoadmapsBranch extends StatefulShellBranchData {
  const RoadmapsBranch();
}

class PracticeHubBranch extends StatefulShellBranchData {
  const PracticeHubBranch();
}

class ProfileBranch extends StatefulShellBranchData {
  const ProfileBranch();
}

class RootRoute extends GoRouteData with $RootRoute {
  const RootRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return BlocProvider(
      create: (_) => getIt<ExploreCubit>()..load(),
      child: const ExploreScreen(),
    );
  }
}

class RoadmapsRoute extends GoRouteData with $RoadmapsRoute {
  const RoadmapsRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return BlocProvider(
      create: (_) => getIt<RoadmapsCubit>()..load(),
      child: const RoadmapsScreen(),
    );
  }
}

class TrackDetailRoute extends GoRouteData with $TrackDetailRoute {
  final String trackId;

  const TrackDetailRoute({required this.trackId});

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return BlocProvider(
      create: (_) => getIt<TrackDetailCubit>()..load(trackId),
      child: const TrackDetailScreen(),
    );
  }
}

class PracticeHubRoute extends GoRouteData with $PracticeHubRoute {
  const PracticeHubRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return BlocProvider(
      create: (_) => getIt<PracticeHubCubit>()..load(),
      child: const PracticeHubScreen(),
    );
  }
}

class ProfileRoute extends GoRouteData with $ProfileRoute {
  const ProfileRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return BlocProvider(
      create: (_) => getIt<ProfileCubit>()..load(),
      child: const ProfileScreen(),
    );
  }
}

/// Full-screen practice of one set. [only] restricts it to comma-separated
/// question ids (retry mistakes). [sessionId] resumes an unfinished session.
@TypedGoRoute<PracticeRoute>(
  path: Routes.practiceRoute,
  name: Routes.practiceRoute,
)
class PracticeRoute extends GoRouteData with $PracticeRoute {
  final String setId;
  final String? only;
  final String? sessionId;

  const PracticeRoute({required this.setId, this.only, this.sessionId});

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return BlocProvider(
      create: (_) => getIt<PracticeCubit>()
        ..start(
          setId,
          onlyQuestionIds: only?.split(','),
          sessionId: sessionId,
        ),
      child: const PracticeScreen(),
    );
  }
}

@TypedGoRoute<ResultRoute>(path: Routes.resultRoute, name: Routes.resultRoute)
class ResultRoute extends GoRouteData with $ResultRoute {
  final String sessionId;

  const ResultRoute({required this.sessionId});

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return BlocProvider(
      create: (_) => getIt<ResultCubit>()..load(sessionId),
      child: const ResultScreen(),
    );
  }
}

class CircleLoading extends StatelessWidget {
  final String? title;
  const CircleLoading({super.key, this.title});

  @override
  Widget build(BuildContext context) {
    return PopScope(
      child: SizedBox(
        height: 100.h,
        width: 100.w,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            title != null
                ? DefaultTextStyle(
                    style: TextStyle(fontSize: 13.sp, color: mCL),
                    child: Text(title!),
                  )
                : const SizedBox.shrink(),
          ],
        ),
      ),
    );
  }
}
