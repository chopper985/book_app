// Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Package imports:
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

// Project imports:
import 'package:interview_practice/core/app/colors/app_palette.dart';
import 'package:interview_practice/core/app/languages/data/localization.dart';
import 'package:interview_practice/core/app/themes/data/app_text.dart';
import 'package:interview_practice/core/utils/sizer/design_size.dart';
import 'package:interview_practice/features/content/presentation/extensions/localized_text_extension.dart';
import 'package:interview_practice/features/profile/domain/entities/learner_profile.dart';
import 'package:interview_practice/features/profile/presentation/cubit/edit_profile_cubit.dart';
import 'package:interview_practice/features/profile/presentation/extensions/profile_labels.dart';
import 'package:interview_practice/features/profile/presentation/widgets/profile_form_fields.dart';
import 'package:interview_practice/features/profile/presentation/widgets/profile_sections.dart';

/// Avatar, personal details and interview preferences.
class EditProfileScreen extends StatelessWidget {
  const EditProfileScreen({super.key});

  /// Max edge of a picked photo; keeps the stored avatar small.
  static const double _avatarMaxSize = 512;

  static Future<bool> _confirmDiscard(BuildContext context) async {
    final discard = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppPalette.surfaceContainer,
        title: Text(
          Strings.editProfileDiscardTitle.i18n,
          style: AppText.sans(18, height: 26, weight: FontWeight.w600),
        ),
        content: Text(
          Strings.editProfileDiscardMessage.i18n,
          style: AppText.sans(
            14,
            height: 20,
            color: AppPalette.onSurfaceVariant,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(
              Strings.editProfileKeepEditing.i18n,
              style: AppText.sans(14, weight: FontWeight.w600),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(
              Strings.editProfileDiscardConfirm.i18n,
              style: AppText.sans(
                14,
                weight: FontWeight.w600,
                color: AppPalette.error,
              ),
            ),
          ),
        ],
      ),
    );
    return discard ?? false;
  }

  Future<void> _leave(BuildContext context) async {
    final dirty = context.read<EditProfileCubit>().state.isDirty;
    if (!dirty || await _confirmDiscard(context)) {
      if (context.mounted) context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<EditProfileCubit>();
    return BlocConsumer<EditProfileCubit, EditProfileState>(
      listenWhen: (previous, current) => !previous.saved && current.saved,
      listener: (context, _) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(Strings.editProfileSaved.i18n)),
        );
        context.pop();
      },
      builder: (context, state) {
        final fields = state.fields;
        return PopScope(
          canPop: !state.isDirty || state.saved,
          onPopInvokedWithResult: (didPop, _) {
            if (!didPop) _leave(context);
          },
          child: Scaffold(
            backgroundColor: AppPalette.surface,
            body: SafeArea(
              child: Column(
                children: [
                  _TopBar(onBack: () => _leave(context)),
                  Expanded(
                    child: fields == null
                        ? const SizedBox.shrink()
                        : _Form(state: state, fields: fields),
                  ),
                  _SaveButton(
                    loading: state.saving,
                    onTap: state.canSave ? cubit.save : null,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _TopBar extends StatelessWidget {
  final VoidCallback onBack;

  const _TopBar({required this.onBack});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 56.dsp,
      child: Row(
        children: [
          SizedBox(width: 4.dsp),
          IconButton(
            tooltip: MaterialLocalizations.of(context).backButtonTooltip,
            onPressed: onBack,
            icon: Icon(
              Icons.arrow_back,
              size: 20.dsp,
              color: AppPalette.onSurface,
            ),
          ),
          SizedBox(width: 4.dsp),
          Expanded(
            child: Text(
              Strings.editProfileTitle.i18n,
              style: AppText.sans(18, height: 26, weight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}

class _Form extends StatelessWidget {
  final EditProfileState state;
  final ProfileFields fields;

  const _Form({required this.state, required this.fields});

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<EditProfileCubit>();
    final today = DateUtils.dateOnly(DateTime.now());
    final email = fields.email ?? '';
    final phone = fields.phone ?? '';

    return ListView(
      padding: EdgeInsets.fromLTRB(16.dsp, 8.dsp, 16.dsp, 24.dsp),
      children: [
        Center(
          child: _AvatarEditor(
            path: state.avatarPath,
            name: fields.displayName,
            hasAvatar: state.avatarPath != null,
          ),
        ),
        SizedBox(height: 24.dsp),
        ProfileSectionTitle(Strings.editProfilePersonal.i18n),
        FieldLabel(Strings.editProfileName.i18n, required: true),
        ProfileTextField(
          initial: fields.displayName,
          maxLength: ProfileFields.maxNameLength,
          textCapitalization: TextCapitalization.words,
          errorText: ProfileFields.isValidName(fields.displayName)
              ? null
              : Strings.editProfileNameError.i18n,
          onChanged: cubit.setName,
        ),
        SizedBox(height: 8.dsp),
        FieldLabel(Strings.editProfileEmail.i18n),
        ProfileTextField(
          initial: email,
          hint: 'name@example.com',
          keyboardType: TextInputType.emailAddress,
          errorText: ProfileFields.isValidEmail(email)
              ? null
              : Strings.editProfileEmailError.i18n,
          onChanged: cubit.setEmail,
        ),
        SizedBox(height: 16.dsp),
        FieldLabel(Strings.editProfilePhone.i18n),
        ProfileTextField(
          initial: phone,
          hint: '0912 345 678',
          keyboardType: TextInputType.phone,
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'[0-9+ .\-]')),
            LengthLimitingTextInputFormatter(20),
          ],
          errorText: ProfileFields.isValidPhone(phone)
              ? null
              : Strings.editProfilePhoneError.i18n,
          onChanged: cubit.setPhone,
          textInputAction: TextInputAction.done,
        ),
        SizedBox(height: 16.dsp),
        FieldLabel(Strings.editProfileBirthDate.i18n),
        DatePickerField(
          date: fields.birthDate,
          placeholder: Strings.onboardingPickDate.i18n,
          firstDate: DateTime(today.year - 80),
          lastDate: today,
          initialDate: DateTime(today.year - 22, today.month, today.day),
          onChanged: cubit.setBirthDate,
        ),
        SizedBox(height: 8.dsp),
        Text(
          Strings.editProfileLocalNote.i18n,
          style: AppText.sans(
            12,
            height: 16,
            color: AppPalette.onSurfaceVariant,
          ),
        ),
        SizedBox(height: 24.dsp),
        ProfileSectionTitle(Strings.editProfileCareer.i18n),
        FieldLabel(Strings.editProfileRole.i18n, required: true),
        _ChipWrap(
          children: [
            for (final role in TargetRole.values)
              SelectChip(
                label: role.label,
                selected: fields.role == role,
                onTap: () => cubit.selectRole(role),
              ),
          ],
        ),
        SizedBox(height: 16.dsp),
        FieldLabel(Strings.editProfileExperience.i18n, required: true),
        _ChipWrap(
          children: [
            for (final experience in ExperienceLevel.values)
              SelectChip(
                label: experience.label,
                selected: fields.experience == experience,
                onTap: () => cubit.selectExperience(experience),
              ),
          ],
        ),
        SizedBox(height: 16.dsp),
        FieldLabel(Strings.editProfileStack.i18n, required: true),
        _ChipWrap(
          children: [
            for (final overview in state.tracks)
              SelectChip(
                label: overview.track.name.text,
                selected: fields.techStack.contains(overview.track.id),
                onTap: () => cubit.toggleTrack(overview.track.id),
              ),
          ],
        ),
        SizedBox(height: 16.dsp),
        FieldLabel(Strings.editProfileInterviewDate.i18n),
        DatePickerField(
          date: fields.interviewDate,
          placeholder: Strings.onboardingPickDate.i18n,
          firstDate: today,
          lastDate: today.add(const Duration(days: 365)),
          initialDate: today.add(const Duration(days: 7)),
          onChanged: cubit.setInterviewDate,
        ),
      ],
    );
  }
}

class _ChipWrap extends StatelessWidget {
  final List<Widget> children;

  const _ChipWrap({required this.children});

  @override
  Widget build(BuildContext context) {
    return Wrap(spacing: 8.dsp, runSpacing: 8.dsp, children: children);
  }
}

class _AvatarEditor extends StatelessWidget {
  final String? path;
  final String name;
  final bool hasAvatar;

  const _AvatarEditor({
    required this.path,
    required this.name,
    required this.hasAvatar,
  });

  Future<void> _pick(BuildContext context, ImageSource source) async {
    final cubit = context.read<EditProfileCubit>();
    final messenger = ScaffoldMessenger.of(context);
    try {
      final image = await ImagePicker().pickImage(
        source: source,
        maxWidth: EditProfileScreen._avatarMaxSize,
        maxHeight: EditProfileScreen._avatarMaxSize,
        imageQuality: 85,
      );
      if (image != null) cubit.pickAvatar(image.path);
    } on PlatformException {
      messenger.showSnackBar(
        SnackBar(content: Text(Strings.editProfileAvatarError.i18n)),
      );
    }
  }

  Future<void> _showOptions(BuildContext context) async {
    final cubit = context.read<EditProfileCubit>();
    final source = await showModalBottomSheet<Object>(
      context: context,
      backgroundColor: AppPalette.surfaceContainer,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16.dsp)),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(height: 8.dsp),
            _SheetOption(
              icon: Icons.photo_library_outlined,
              label: Strings.editProfileFromGallery.i18n,
              onTap: () => Navigator.of(context).pop(ImageSource.gallery),
            ),
            _SheetOption(
              icon: Icons.photo_camera_outlined,
              label: Strings.editProfileFromCamera.i18n,
              onTap: () => Navigator.of(context).pop(ImageSource.camera),
            ),
            if (hasAvatar)
              _SheetOption(
                icon: Icons.delete_outline,
                label: Strings.editProfileRemoveAvatar.i18n,
                color: AppPalette.error,
                onTap: () => Navigator.of(context).pop(false),
              ),
            SizedBox(height: 8.dsp),
          ],
        ),
      ),
    );
    if (!context.mounted) return;
    if (source is ImageSource) {
      await _pick(context, source);
    } else if (source == false) {
      cubit.removeAvatar();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: Strings.editProfileAvatar.i18n,
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: () => _showOptions(context),
        child: Column(
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                ProfileAvatar(path: path, name: name, size: 96),
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: Container(
                    width: 30.dsp,
                    height: 30.dsp,
                    decoration: BoxDecoration(
                      color: AppPalette.primaryStrong,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppPalette.surface, width: 2),
                    ),
                    child: Icon(
                      Icons.photo_camera,
                      size: 14.dsp,
                      color: AppPalette.onPrimaryStrong,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 8.dsp),
            Text(
              Strings.editProfileAvatar.i18n,
              style: AppText.sans(
                13,
                height: 18,
                weight: FontWeight.w600,
                color: AppPalette.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SheetOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _SheetOption({
    required this.icon,
    required this.label,
    required this.onTap,
    this.color = AppPalette.onSurface,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, size: 22.dsp, color: color),
      title: Text(
        label,
        style: AppText.sans(15, height: 22, color: color),
      ),
      onTap: onTap,
    );
  }
}

class _SaveButton extends StatelessWidget {
  final bool loading;
  final VoidCallback? onTap;

  const _SaveButton({required this.loading, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final enabled = onTap != null;
    final radius = BorderRadius.circular(8.dsp);
    return Padding(
      padding: EdgeInsets.fromLTRB(16.dsp, 8.dsp, 16.dsp, 16.dsp),
      child: Material(
        color: enabled ? AppPalette.primaryStrong : AppPalette.surfaceHigh,
        borderRadius: radius,
        child: InkWell(
          borderRadius: radius,
          onTap: onTap,
          child: SizedBox(
            height: 52.dsp,
            child: Center(
              child: loading
                  ? SizedBox.square(
                      dimension: 20.dsp,
                      child: const CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppPalette.onPrimaryStrong,
                      ),
                    )
                  : Text(
                      Strings.profileSave.i18n,
                      style: AppText.sans(
                        16,
                        height: 24,
                        weight: FontWeight.w600,
                        color: enabled
                            ? AppPalette.onPrimaryStrong
                            : AppPalette.onSurfaceVariant,
                      ),
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
