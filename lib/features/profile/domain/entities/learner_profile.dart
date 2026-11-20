// Package imports:
import 'package:equatable/equatable.dart';

/// Position the learner is preparing for.
enum TargetRole { mobile, frontend, backend, fullstack }

/// Experience, used to pick question levels and the header label.
enum ExperienceLevel { student, fresher, junior, middle }

/// Everything the learner can edit. Personal fields are optional.
class ProfileFields extends Equatable {
  static const int maxNameLength = 30;
  static const int minPhoneDigits = 9;
  static const int maxPhoneDigits = 15;

  static final RegExp _email = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
  static final RegExp _phoneChars = RegExp(r'^\+?[0-9 .\-]+$');

  final String displayName;
  final TargetRole role;
  final ExperienceLevel experience;

  /// Track ids the learner works with, in the order they were picked.
  final List<String> techStack;
  final DateTime? interviewDate;
  final DateTime? birthDate;
  final String? email;
  final String? phone;

  /// File name of the avatar inside the app's avatar folder. Only the name
  /// is stored because the app directory path can change between installs.
  final String? avatarFileName;

  const ProfileFields({
    required this.displayName,
    required this.role,
    required this.experience,
    required this.techStack,
    this.interviewDate,
    this.birthDate,
    this.email,
    this.phone,
    this.avatarFileName,
  });

  static bool isValidName(String name) {
    final trimmed = name.trim();
    return trimmed.isNotEmpty && trimmed.length <= maxNameLength;
  }

  /// Empty is valid: the email is optional.
  static bool isValidEmail(String email) {
    final trimmed = email.trim();
    return trimmed.isEmpty || _email.hasMatch(trimmed);
  }

  /// Empty is valid. Allows `+`, spaces, dots and dashes between digits.
  static bool isValidPhone(String phone) {
    final trimmed = phone.trim();
    if (trimmed.isEmpty) return true;
    if (!_phoneChars.hasMatch(trimmed)) return false;
    final digits = trimmed.replaceAll(RegExp('[^0-9]'), '').length;
    return digits >= minPhoneDigits && digits <= maxPhoneDigits;
  }

  bool get isValid =>
      isValidName(displayName) &&
      techStack.isNotEmpty &&
      isValidEmail(email ?? '') &&
      isValidPhone(phone ?? '');

  /// Trims text and turns empty optional text into `null`.
  ProfileFields normalized() => ProfileFields(
        displayName: displayName.trim(),
        role: role,
        experience: experience,
        techStack: List.unmodifiable(techStack),
        interviewDate: interviewDate,
        birthDate: birthDate,
        email: _blankToNull(email),
        phone: _blankToNull(phone),
        avatarFileName: avatarFileName,
      );

  static String? _blankToNull(String? value) {
    final trimmed = value?.trim();
    return trimmed == null || trimmed.isEmpty ? null : trimmed;
  }

  ProfileFields copyWith({
    String? displayName,
    TargetRole? role,
    ExperienceLevel? experience,
    List<String>? techStack,
    DateTime? Function()? interviewDate,
    DateTime? Function()? birthDate,
    String? Function()? email,
    String? Function()? phone,
    String? Function()? avatarFileName,
  }) {
    return ProfileFields(
      displayName: displayName ?? this.displayName,
      role: role ?? this.role,
      experience: experience ?? this.experience,
      techStack: techStack ?? this.techStack,
      interviewDate:
          interviewDate == null ? this.interviewDate : interviewDate(),
      birthDate: birthDate == null ? this.birthDate : birthDate(),
      email: email == null ? this.email : email(),
      phone: phone == null ? this.phone : phone(),
      avatarFileName:
          avatarFileName == null ? this.avatarFileName : avatarFileName(),
    );
  }

  @override
  List<Object?> get props => [
        displayName,
        role,
        experience,
        techStack,
        interviewDate,
        birthDate,
        email,
        phone,
        avatarFileName,
      ];
}

/// The saved profile, stored on the device. Has [updatedAt] so it can be
/// synced to the cloud later.
class LearnerProfile extends Equatable {
  static const int maxNameLength = ProfileFields.maxNameLength;

  final ProfileFields fields;
  final DateTime createdAt;
  final DateTime updatedAt;

  const LearnerProfile({
    required this.fields,
    required this.createdAt,
    required this.updatedAt,
  });

  String get displayName => fields.displayName;

  TargetRole get role => fields.role;

  ExperienceLevel get experience => fields.experience;

  List<String> get techStack => fields.techStack;

  DateTime? get interviewDate => fields.interviewDate;

  DateTime? get birthDate => fields.birthDate;

  String? get email => fields.email;

  String? get phone => fields.phone;

  String? get avatarFileName => fields.avatarFileName;

  /// Whole days from [now] to the interview; `null` when none is set or it
  /// has passed.
  int? daysToInterview(DateTime now) {
    final date = interviewDate;
    if (date == null) return null;
    final today = DateTime(now.year, now.month, now.day);
    final day = DateTime(date.year, date.month, date.day);
    final days = (day.difference(today).inHours / 24).round();
    return days < 0 ? null : days;
  }

  @override
  List<Object?> get props => [fields, createdAt, updatedAt];
}
