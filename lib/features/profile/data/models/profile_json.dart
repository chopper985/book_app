// Project imports:
import 'package:AppName/features/profile/domain/entities/learner_profile.dart';

/// JSON mapping of [LearnerProfile]. Dates are UTC epoch milliseconds; the
/// interview date is a calendar day stored as `yyyy-MM-dd`.
class ProfileJson {
  const ProfileJson._();

  static Map<String, dynamic> toJson(LearnerProfile profile) => {
        'displayName': profile.displayName,
        'role': profile.role.name,
        'experience': profile.experience.name,
        'techStack': profile.techStack,
        if (profile.interviewDate != null)
          'interviewDate': _day(profile.interviewDate!),
        'createdAt': profile.createdAt.toUtc().millisecondsSinceEpoch,
        'updatedAt': profile.updatedAt.toUtc().millisecondsSinceEpoch,
      };

  static LearnerProfile fromJson(Map<String, dynamic> json) => LearnerProfile(
        displayName: json['displayName'] as String,
        role: TargetRole.values.byName(json['role'] as String),
        experience: ExperienceLevel.values.byName(json['experience'] as String),
        techStack: List<String>.unmodifiable(json['techStack'] as List),
        interviewDate: json['interviewDate'] == null
            ? null
            : DateTime.parse(json['interviewDate'] as String),
        createdAt: _date(json['createdAt'] as int),
        updatedAt: _date(json['updatedAt'] as int),
      );

  static String _day(DateTime date) =>
      '${date.year.toString().padLeft(4, '0')}-'
      '${date.month.toString().padLeft(2, '0')}-'
      '${date.day.toString().padLeft(2, '0')}';

  static DateTime _date(int millis) =>
      DateTime.fromMillisecondsSinceEpoch(millis, isUtc: true).toLocal();
}
