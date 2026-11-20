// Project imports:
import 'package:interview_practice/core/app/languages/data/localization.dart';
import 'package:interview_practice/features/content/domain/entities/question.dart';

extension QuestionLevelLabel on QuestionLevel {
  String get label => switch (this) {
        QuestionLevel.fresher => Strings.levelFresher,
        QuestionLevel.junior => Strings.levelJunior,
        QuestionLevel.middle => Strings.levelMiddle,
        QuestionLevel.senior => Strings.levelSenior,
      }
          .i18n;
}
