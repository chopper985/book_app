// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_router.dart';

// **************************************************************************
// GoRouterGenerator
// **************************************************************************

List<RouteBase> get $appRoutes => [
      $onboardingRoute,
      $mainShellRoute,
      $practiceRoute,
      $resultRoute,
    ];

RouteBase get $onboardingRoute => GoRouteData.$route(
      path: '/onboarding',
      name: '/onboarding',
      hasOverriddenOnExit: false,
      factory: $OnboardingRoute._fromState,
    );

mixin $OnboardingRoute on GoRouteData {
  static OnboardingRoute _fromState(GoRouterState state) =>
      const OnboardingRoute();

  @override
  String get location => GoRouteData.$location(
        '/onboarding',
      );

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

RouteBase get $mainShellRoute => StatefulShellRouteData.$route(
      factory: $MainShellRouteExtension._fromState,
      branches: [
        StatefulShellBranchData.$branch(
          routes: [
            GoRouteData.$route(
              path: '/',
              name: '/',
              hasOverriddenOnExit: false,
              factory: $RootRoute._fromState,
            ),
          ],
        ),
        StatefulShellBranchData.$branch(
          routes: [
            GoRouteData.$route(
              path: '/roadmaps',
              name: '/roadmaps',
              hasOverriddenOnExit: false,
              factory: $RoadmapsRoute._fromState,
              routes: [
                GoRouteData.$route(
                  path: ':trackId',
                  name: ':trackId',
                  hasOverriddenOnExit: false,
                  factory: $TrackDetailRoute._fromState,
                ),
              ],
            ),
          ],
        ),
        StatefulShellBranchData.$branch(
          routes: [
            GoRouteData.$route(
              path: '/practice-hub',
              name: '/practice-hub',
              hasOverriddenOnExit: false,
              factory: $PracticeHubRoute._fromState,
            ),
          ],
        ),
        StatefulShellBranchData.$branch(
          routes: [
            GoRouteData.$route(
              path: '/profile',
              name: '/profile',
              hasOverriddenOnExit: false,
              factory: $ProfileRoute._fromState,
            ),
          ],
        ),
      ],
    );

extension $MainShellRouteExtension on MainShellRoute {
  static MainShellRoute _fromState(GoRouterState state) =>
      const MainShellRoute();
}

mixin $RootRoute on GoRouteData {
  static RootRoute _fromState(GoRouterState state) => const RootRoute();

  @override
  String get location => GoRouteData.$location(
        '/',
      );

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

mixin $RoadmapsRoute on GoRouteData {
  static RoadmapsRoute _fromState(GoRouterState state) => const RoadmapsRoute();

  @override
  String get location => GoRouteData.$location(
        '/roadmaps',
      );

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

mixin $TrackDetailRoute on GoRouteData {
  static TrackDetailRoute _fromState(GoRouterState state) => TrackDetailRoute(
        trackId: state.pathParameters['trackId']!,
      );

  TrackDetailRoute get _self => this as TrackDetailRoute;

  @override
  String get location => GoRouteData.$location(
        '/roadmaps/${Uri.encodeComponent(_self.trackId)}',
      );

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

mixin $PracticeHubRoute on GoRouteData {
  static PracticeHubRoute _fromState(GoRouterState state) =>
      const PracticeHubRoute();

  @override
  String get location => GoRouteData.$location(
        '/practice-hub',
      );

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

mixin $ProfileRoute on GoRouteData {
  static ProfileRoute _fromState(GoRouterState state) => const ProfileRoute();

  @override
  String get location => GoRouteData.$location(
        '/profile',
      );

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

RouteBase get $practiceRoute => GoRouteData.$route(
      path: '/practice/:setId',
      name: '/practice/:setId',
      hasOverriddenOnExit: false,
      factory: $PracticeRoute._fromState,
    );

mixin $PracticeRoute on GoRouteData {
  static PracticeRoute _fromState(GoRouterState state) => PracticeRoute(
        setId: state.pathParameters['setId']!,
        only: state.uri.queryParameters['only'],
        sessionId: state.uri.queryParameters['session-id'],
      );

  PracticeRoute get _self => this as PracticeRoute;

  @override
  String get location => GoRouteData.$location(
        '/practice/${Uri.encodeComponent(_self.setId)}',
        queryParams: {
          if (_self.only != null) 'only': _self.only,
          if (_self.sessionId != null) 'session-id': _self.sessionId,
        },
      );

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

RouteBase get $resultRoute => GoRouteData.$route(
      path: '/result/:sessionId',
      name: '/result/:sessionId',
      hasOverriddenOnExit: false,
      factory: $ResultRoute._fromState,
    );

mixin $ResultRoute on GoRouteData {
  static ResultRoute _fromState(GoRouterState state) => ResultRoute(
        sessionId: state.pathParameters['sessionId']!,
      );

  ResultRoute get _self => this as ResultRoute;

  @override
  String get location => GoRouteData.$location(
        '/result/${Uri.encodeComponent(_self.sessionId)}',
      );

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}
