// Package imports:
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:material_ui/material_ui.dart';

// Project imports:
import 'package:interview_practice/core/app/themes/service/theme_service.dart';

part 'theme_state.dart';

@injectable
class ThemeCubit extends Cubit<ThemeState> {
  ThemeCubit() : super(ThemeInitial());

  ThemeMode currentThemeMode = ThemeMode.light;

  updateTheme(ThemeMode mode) {
    ThemeService().changeThemeMode(mode: currentThemeMode);
    emit(ThemeUpdated(mode: currentThemeMode));
  }
}
