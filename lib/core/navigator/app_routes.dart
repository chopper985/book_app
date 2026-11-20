class Routes {
  // Root & Authentication
  static const String rootRoute = '/';
  static const String authenticationRoute = '/authentication';
  static const String loginRoute = '/login';
  static const String onboardingRoute = '/onboarding';
  static const String editProfileRoute = '/profile-edit';

  // Bottom navigation tabs
  static const String roadmapsRoute = '/roadmaps';
  static const String practiceHubRoute = '/practice-hub';
  static const String profileRoute = '/profile';

  // Catalog (child of roadmaps)
  static const String trackDetailRoute = ':trackId';

  // Practice (full screen, outside the tabs)
  static const String practiceRoute = '/practice/:setId';
  static const String resultRoute = '/result/:sessionId';
}
