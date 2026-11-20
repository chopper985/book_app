// Project imports:
import 'package:interview_practice/core/app/languages/data/localization.dart';
import 'package:interview_practice/features/profile/domain/entities/learner_profile.dart';

extension TargetRoleLabel on TargetRole {
  String get label => switch (this) {
        TargetRole.mobile => Strings.roleMobile,
        TargetRole.frontend => Strings.roleFrontend,
        TargetRole.backend => Strings.roleBackend,
        TargetRole.fullstack => Strings.roleFullstack,
      }
          .i18n;
}

extension ExperienceLevelLabel on ExperienceLevel {
  String get label => switch (this) {
        ExperienceLevel.student => Strings.experienceStudent,
        ExperienceLevel.fresher => Strings.experienceFresher,
        ExperienceLevel.junior => Strings.experienceJunior,
        ExperienceLevel.middle => Strings.experienceMiddle,
      }
          .i18n;

  String get hint => switch (this) {
        ExperienceLevel.student => Strings.experienceStudentHint,
        ExperienceLevel.fresher => Strings.experienceFresherHint,
        ExperienceLevel.junior => Strings.experienceJuniorHint,
        ExperienceLevel.middle => Strings.experienceMiddleHint,
      }
          .i18n;
}

extension HeaderRoleLabel on ExperienceLevel? {
  /// Short role shown in the app header, e.g. "Junior Dev".
  String get headerLabel => switch (this) {
        ExperienceLevel.student => Strings.headerIntern,
        ExperienceLevel.fresher => Strings.headerFresher,
        ExperienceLevel.junior => Strings.headerJunior,
        ExperienceLevel.middle => Strings.headerMiddle,
        null => Strings.headerDefault,
      }
          .i18n;
}
