// Package imports:
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

// Project imports:
import 'package:AppName/core/analytics/app_analytics.dart';
import 'package:AppName/features/catalog/domain/entities/track_overview.dart';
import 'package:AppName/features/catalog/domain/usecase/get_explore_data.dart';
import 'package:AppName/features/profile/domain/entities/learner_profile.dart';
import 'package:AppName/features/profile/domain/usecase/profile_usecases.dart';

part 'edit_profile_state.dart';

@injectable
class EditProfileCubit extends Cubit<EditProfileState> {
  final GetProfile _getProfile;
  final GetAvatarPath _getAvatarPath;
  final StoreAvatar _storeAvatar;
  final SaveProfile _saveProfile;
  final GetTracks _getTracks;
  final AppAnalytics _analytics;

  EditProfileCubit(
    this._getProfile,
    this._getAvatarPath,
    this._storeAvatar,
    this._saveProfile,
    this._getTracks, {
    AppAnalytics analytics = const NoopAppAnalytics(),
  })  : _analytics = analytics,
        super(const EditProfileState());

  /// Fills the form synchronously so text fields start with saved values,
  /// then loads tracks and the avatar file.
  Future<void> load() async {
    final fields = _getProfile()?.fields;
    emit(EditProfileState(original: fields, fields: fields));
    final tracks = (await _getTracks()).value ?? const <TrackOverview>[];
    final avatar = await _getAvatarPath(fields?.avatarFileName);
    if (isClosed) return;
    emit(state.copyWith(tracks: tracks, storedAvatarPath: () => avatar));
  }

  void setName(String value) => _update((f) => f.copyWith(displayName: value));

  void setEmail(String value) => _update((f) => f.copyWith(email: () => value));

  void setPhone(String value) => _update((f) => f.copyWith(phone: () => value));

  void setBirthDate(DateTime? date) =>
      _update((f) => f.copyWith(birthDate: () => date));

  void setInterviewDate(DateTime? date) =>
      _update((f) => f.copyWith(interviewDate: () => date));

  void selectRole(TargetRole role) => _update((f) => f.copyWith(role: role));

  void selectExperience(ExperienceLevel experience) =>
      _update((f) => f.copyWith(experience: experience));

  void toggleTrack(String trackId) => _update((f) {
        final stack = [...f.techStack];
        if (!stack.remove(trackId)) stack.add(trackId);
        return f.copyWith(techStack: stack);
      });

  void pickAvatar(String path) =>
      emit(state.copyWith(pickedAvatarPath: () => path));

  /// Clears both a new pick and the saved avatar.
  void removeAvatar() {
    final fields = state.fields;
    if (fields == null) return;
    emit(
      state.copyWith(
        pickedAvatarPath: () => null,
        fields: fields.copyWith(avatarFileName: () => null),
      ),
    );
  }

  Future<void> save() async {
    if (!state.canSave) return;
    emit(state.copyWith(saving: true));
    var fields = state.fields!;
    final picked = state.pickedAvatarPath;
    if (picked != null) {
      final name = await _storeAvatar(picked);
      fields = fields.copyWith(avatarFileName: () => name);
    }
    final avatarChanged =
        fields.avatarFileName != state.original?.avatarFileName;
    final profile = await _saveProfile(fields);
    _analytics
      ..profileUpdated(
        avatarChanged: avatarChanged,
        experience: profile.experience.name,
      )
      ..setUserProperty('role', profile.role.name)
      ..setUserProperty('experience', profile.experience.name);
    if (!isClosed) emit(state.copyWith(saving: false, saved: true));
  }

  void _update(ProfileFields Function(ProfileFields fields) change) {
    final fields = state.fields;
    if (fields == null || state.saving) return;
    emit(state.copyWith(fields: change(fields)));
  }
}
