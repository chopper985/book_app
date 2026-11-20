part of 'edit_profile_cubit.dart';

class EditProfileState extends Equatable {
  /// Saved values; `null` before loading or without a profile.
  final ProfileFields? original;
  final ProfileFields? fields;

  /// Absolute path of the saved avatar, resolved from its file name.
  final String? storedAvatarPath;

  /// Image picked in this session, copied into app storage on save.
  final String? pickedAvatarPath;
  final List<TrackOverview> tracks;
  final bool saving;
  final bool saved;

  const EditProfileState({
    this.original,
    this.fields,
    this.storedAvatarPath,
    this.pickedAvatarPath,
    this.tracks = const [],
    this.saving = false,
    this.saved = false,
  });

  /// What the avatar shows now: the new pick, else the saved one unless it
  /// was removed.
  String? get avatarPath =>
      pickedAvatarPath ??
      (fields?.avatarFileName == null ? null : storedAvatarPath);

  /// Compares normalized values, so typing then clearing a field is not a
  /// change.
  bool get isDirty =>
      pickedAvatarPath != null ||
      fields?.normalized() != original?.normalized();

  bool get canSave =>
      fields != null && fields!.isValid && isDirty && !saving && !saved;

  EditProfileState copyWith({
    ProfileFields? original,
    ProfileFields? fields,
    String? Function()? storedAvatarPath,
    String? Function()? pickedAvatarPath,
    List<TrackOverview>? tracks,
    bool? saving,
    bool? saved,
  }) {
    return EditProfileState(
      original: original ?? this.original,
      fields: fields ?? this.fields,
      storedAvatarPath: storedAvatarPath == null
          ? this.storedAvatarPath
          : storedAvatarPath(),
      pickedAvatarPath: pickedAvatarPath == null
          ? this.pickedAvatarPath
          : pickedAvatarPath(),
      tracks: tracks ?? this.tracks,
      saving: saving ?? this.saving,
      saved: saved ?? this.saved,
    );
  }

  @override
  List<Object?> get props => [
        original,
        fields,
        storedAvatarPath,
        pickedAvatarPath,
        tracks,
        saving,
        saved,
      ];
}
