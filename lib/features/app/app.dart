// Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Package imports:
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:i18n_extension/i18n_extension.dart';
import 'package:sizer/sizer.dart';

// Project imports:
import 'package:interview_practice/core/app/languages/service/service.dart';
import 'package:interview_practice/core/app/themes/data/app_themes.dart';
import 'package:interview_practice/core/navigator/app_router.dart';
import 'package:interview_practice/features/app/cubit/cubit.dart';

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<StatefulWidget> createState() => _AppState();
}

class _AppState extends State<App> {
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: AppCubit.providers,
      child: Sizer(
        builder: (context, orientation, deviceType) {
          // Screens without an AppBar would otherwise fall back to the
          // platform default (dark icons on the dark UI).
          return AnnotatedRegion<SystemUiOverlayStyle>(
            value: AppTheme.systemOverlayStyle,
            child: MaterialApp.router(
              title: "DevInterview",
              routerConfig: AppRouter.instance.router,
              // Follows the in-app language so dates and pickers match it.
              locale: context.locale,
              debugShowCheckedModeBanner: false,
              theme: AppTheme.dark().data,
              themeMode: ThemeMode.dark,
              supportedLocales: LanguageService.supportLanguages,
              localizationsDelegates: const [
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
            ),
          );
        },
      ),
    );
  }
}
