// Flutter imports:
import 'package:material_ui/material_ui.dart';

// Package imports:
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

// Project imports:
import 'package:interview_practice/core/app/colors/app_palette.dart';
import 'package:interview_practice/core/app/languages/data/localization.dart';
import 'package:interview_practice/core/utils/sizer/design_size.dart';
import 'package:interview_practice/features/catalog/presentation/cubit/roadmap_picker_cubit.dart';
import 'package:interview_practice/features/catalog/presentation/widgets/roadmap_picker_view.dart';

/// Full-screen "Add a roadmap". Pops with `true` once a roadmap is added.
class RoadmapPickerScreen extends StatelessWidget {
  const RoadmapPickerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<RoadmapPickerCubit, RoadmapPickerState>(
      listenWhen: (previous, current) =>
          current is RoadmapPickerLoaded &&
          current.done &&
          !(previous is RoadmapPickerLoaded && previous.done),
      listener: (context, _) => context.pop(true),
      child: Scaffold(
        backgroundColor: AppPalette.surface,
        // The header handles the top inset; the bottom inset keeps the
        // confirm button above the system navigation bar.
        body: SafeArea(
          top: false,
          child: RoadmapPickerView(
            title: Strings.pickerAddTitle.i18n,
            subtitle: Strings.pickerSubtitle.i18n,
            primary: true,
            leading: IconButton(
              tooltip: MaterialLocalizations.of(context).backButtonTooltip,
              onPressed: () => context.pop(false),
              icon: Icon(
                Icons.arrow_back,
                size: 20.dsp,
                color: AppPalette.onSurface,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
