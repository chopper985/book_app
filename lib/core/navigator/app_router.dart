// Dart imports:
import 'dart:async';

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:sizer/sizer.dart';

// Project imports:
import 'package:interview_practice/core/analytics/app_analytics.dart';
import 'package:interview_practice/core/app/colors/app_colors.dart';
import 'package:interview_practice/core/injection/injection_container.dart';
import 'package:interview_practice/core/navigator/app_routes.dart';
import 'package:interview_practice/core/navigator/main_shell.dart';
import 'package:interview_practice/features/auth/presentation/cubit/sign_in_cubit.dart';
import 'package:interview_practice/features/auth/presentation/screens/phone_sign_in_screen.dart';
import 'package:interview_practice/features/auth/presentation/screens/sign_in_screen.dart';
import 'package:interview_practice/features/catalog/presentation/cubit/explore_cubit.dart';
import 'package:interview_practice/features/catalog/presentation/cubit/roadmap_picker_cubit.dart';
import 'package:interview_practice/features/catalog/presentation/cubit/track_detail_cubit.dart';
import 'package:interview_practice/features/catalog/presentation/cubit/roadmaps_cubit.dart';
import 'package:interview_practice/features/catalog/presentation/screens/explore_screen.dart';
import 'package:interview_practice/features/catalog/presentation/screens/roadmap_picker_screen.dart';
import 'package:interview_practice/features/catalog/presentation/screens/track_roadmap_screen.dart';
import 'package:interview_practice/features/content/domain/entities/question.dart';
import 'package:interview_practice/features/catalog/presentation/screens/roadmaps_screen.dart';
import 'package:interview_practice/features/practice/presentation/cubit/practice_cubit.dart';
import 'package:interview_practice/features/practice/presentation/cubit/practice_hub_cubit.dart';
import 'package:interview_practice/features/practice/presentation/cubit/result_cubit.dart';
import 'package:interview_practice/features/practice/presentation/screens/practice_hub_screen.dart';
import 'package:interview_practice/features/practice/presentation/screens/practice_screen.dart';
import 'package:interview_practice/features/practice/presentation/screens/result_screen.dart';
import 'package:interview_practice/features/profile/domain/repositories/profile_repository.dart';
import 'package:interview_practice/features/profile/presentation/cubit/edit_profile_cubit.dart';
import 'package:interview_practice/features/profile/presentation/cubit/onboarding_cubit.dart';
import 'package:interview_practice/features/profile/presentation/cubit/profile_cubit.dart';
import 'package:interview_practice/features/profile/presentation/screens/edit_profile_screen.dart';
import 'package:interview_practice/features/profile/presentation/screens/onboarding_screen.dart';
import 'package:interview_practice/features/profile/presentation/screens/profile_screen.dart';

part 'app_router.g.dart';

/// Notifies GoRouter whenever [stream] emits.
class _StreamListenable extends ChangeNotifier {
  late final StreamSubscription<void> _subscription;

  _StreamListenable(Stream<void> stream) {
    _subscription = stream.listen((_) => notifyListeners());
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}

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
      // Re-run the redirect when the profile appears (restored from the
      // cloud after signing in) or disappears (signed out).
      refreshListenable:
          _StreamListenable(getIt<ProfileRepository>().changes),
    );
    router.routerDelegate.addListener(_logScreen);
  }

  /// Logs the route template (e.g. `/roadmaps/:trackId`), never ids, on every
  /// navigation including tab switches.
  void _logScreen() {
    final path = router.routerDelegate.currentConfiguration.fullPath;
    if (path.isNotEmpty) getIt<AppAnalytics>().screenView(path);
  }

  /// Screens a learner without a profile may open: onboarding, and signing
  /// in to an existing account whose profile is then restored.
  static const Set<String> _openWithoutProfile = {
    Routes.onboardingRoute,
    Routes.signInRoute,
    Routes.phoneSignInRoute,
  };

  /// Sends a learner without a profile to onboarding, and away from it once
  /// the profile exists.
  static String? _requireProfile(BuildContext context, GoRouterState state) {
    final hasProfile = getIt<ProfileRepository>().hasProfile;
    final location = state.matchedLocation;
    if (!hasProfile && !_openWithoutProfile.contains(location)) {
      return Routes.onboardingRoute;
    }
    if (hasProfile && location == Routes.onboardingRoute) {
      return Routes.rootRoute;
    }
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

/// Choose Google or phone; pops `true` once signed in.
@TypedGoRoute<SignInRoute>(path: Routes.signInRoute, name: Routes.signInRoute)
class SignInRoute extends GoRouteData with $SignInRoute {
  const SignInRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return BlocProvider(
      create: (_) => getIt<SignInCubit>(),
      child: const SignInScreen(),
    );
  }
}

/// Phone number and SMS code; pops `true` once signed in.
@TypedGoRoute<PhoneSignInRoute>(
  path: Routes.phoneSignInRoute,
  name: Routes.phoneSignInRoute,
)
class PhoneSignInRoute extends GoRouteData with $PhoneSignInRoute {
  const PhoneSignInRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return BlocProvider(
      create: (_) => getIt<SignInCubit>(),
      child: const PhoneSignInScreen(),
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

/// One track opened from a position roadmap, up to [level].
@TypedGoRoute<TrackRoadmapRoute>(
  path: Routes.trackRoadmapRoute,
  name: Routes.trackRoadmapRoute,
)
class TrackRoadmapRoute extends GoRouteData with $TrackRoadmapRoute {
  final String trackId;

  /// `QuestionLevel.name`; every level when missing or unknown.
  final String? level;

  const TrackRoadmapRoute({required this.trackId, this.level});

  @override
  Widget build(BuildContext context, GoRouterState state) {
    final maxLevel =
        QuestionLevel.values.where((value) => value.name == level).firstOrNull;
    return BlocProvider(
      create: (_) =>
          getIt<TrackDetailCubit>()..load(trackId, maxLevel: maxLevel),
      child: const TrackRoadmapScreen(),
    );
  }
}

/// Full-screen "Add a roadmap"; pops `true` once one is added.
@TypedGoRoute<RoadmapPickerRoute>(
  path: Routes.roadmapPickerRoute,
  name: Routes.roadmapPickerRoute,
)
class RoadmapPickerRoute extends GoRouteData with $RoadmapPickerRoute {
  const RoadmapPickerRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return BlocProvider(
      create: (_) => getIt<RoadmapPickerCubit>()..load(),
      child: const RoadmapPickerScreen(),
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
