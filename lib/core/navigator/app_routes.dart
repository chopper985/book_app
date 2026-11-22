class Routes {
  // Root & Authentication
  static const String rootRoute = '/';
  static const String authenticationRoute = '/authentication';
  static const String loginRoute = '/login';
  static const String onboardingRoute = '/onboarding';
  static const String editProfileRoute = '/profile-edit';
  static const String signInRoute = '/sign-in';
  static const String phoneSignInRoute = '/sign-in/phone';
  static const String paywallRoute = '/premium';

  // Bottom navigation tabs
  static const String roadmapsRoute = '/roadmaps';
  static const String practiceHubRoute = '/practice-hub';
  static const String profileRoute = '/profile';

  // Catalog: add a roadmap (full screen)
  static const String roadmapPickerRoute = '/roadmap-picker';

  // One track of a position roadmap (full screen)
  static const String trackRoadmapRoute = '/track/:trackId';

  // Practice (full screen, outside the tabs)
  static const String practiceRoute = '/practice/:setId';
  static const String resultRoute = '/result/:sessionId';
}
