// Package imports:
import 'package:flutter_bloc/flutter_bloc.dart';

// Project imports:
import 'package:interview_practice/core/injection/injection_container.dart';
import 'package:interview_practice/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:interview_practice/features/theme/presentation/cubit/theme_cubit.dart';

class AppCubit {
  static final ThemeCubit themeCubit = getIt<ThemeCubit>();
  static final AuthCubit authCubit = getIt<AuthCubit>();

  static final List<BlocProvider> providers = [
    BlocProvider<ThemeCubit>(
      create: (context) => themeCubit,
    ),
    BlocProvider<AuthCubit>(
      create: (context) => authCubit,
    ),
  ];

  Future<void> bootstrap() async {}

  ///Singleton factory
  static final AppCubit instance = AppCubit._internal();

  factory AppCubit() {
    return instance;
  }

  AppCubit._internal();
}
