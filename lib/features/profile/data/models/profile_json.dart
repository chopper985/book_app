// Project imports:
import 'package:AppName/features/profile/domain/entities/learner_profile.dart';

/// JSON mapping of [LearnerProfile]. Timestamps are UTC epoch milliseconds;
/// calendar days (interview, birth date) are stored as `yyyy-MM-dd`.
class ProfileJson {
  const ProfileJson._();

  static Map<String, dynamic> toJson(LearnerProfile profile) {
    final fields = profile.fields;
    return {
      'displayName': fields.displayName,
      'role': fields.role.name,
      'experience': fields.experience.name,
      'techStack': fields.techStack,
      if (fields.interviewDate != null)
        'interviewDate': _day(fields.interviewDate!),
      if (fields.birthDate != null) 'birthDate': _day(fields.birthDate!),
      if (fields.email != null) 'email': fields.email,
      if (fields.phone != null) 'phone': fields.phone,
      if (fields.avatarFileName != null) 'avatar': fields.avatarFileName,
      'createdAt': profile.createdAt.toUtc().millisecondsSinceEpoch,
      'updatedAt': profile.updatedAt.toUtc().millisecondsSinceEpoch,
    };
  }

  static LearnerProfile fromJson(Map<String, dynamic> json) => LearnerProfile(
        fields: ProfileFields(
          displayName: json['displayName'] as String,
          role: TargetRole.values.byName(json['role'] as String),
          experience:
              ExperienceLevel.values.byName(json['experience'] as String),
          techStack: List<String>.unmodifiable(json['techStack'] as List),
          interviewDate: _dayFrom(json['interviewDate']),
          birthDate: _dayFrom(json['birthDate']),
          email: json['email'] as String?,
          phone: json['phone'] as String?,
          avatarFileName: json['avatar'] as String?,
        ),
        createdAt: _date(json['createdAt'] as int),
        updatedAt: _date(json['updatedAt'] as int),
      );

  static String _day(DateTime date) =>
      '${date.year.toString().padLeft(4, '0')}-'
      '${date.month.toString().padLeft(2, '0')}-'
      '${date.day.toString().padLeft(2, '0')}';

  static DateTime? _dayFrom(Object? value) =>
      value is String ? DateTime.parse(value) : null;

  static DateTime _date(int millis) =>
      DateTime.fromMillisecondsSinceEpoch(millis, isUtc: true).toLocal();
}
