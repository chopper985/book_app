// Package imports:
import 'package:injectable/injectable.dart';

// Project imports:
import 'package:AppName/features/catalog/domain/entities/user_roadmap.dart';
import 'package:AppName/features/catalog/domain/repositories/user_roadmaps_repository.dart';
import 'package:AppName/features/content/domain/entities/question.dart';
import 'package:AppName/features/profile/domain/entities/learner_profile.dart';
import 'package:AppName/features/profile/domain/repositories/profile_repository.dart';

@injectable
class GetUserRoadmaps {
  final UserRoadmapsRepository _repository;

  GetUserRoadmaps(this._repository);

  ({List<UserRoadmap> roadmaps, UserRoadmap? active}) call() =>
      (roadmaps: _repository.roadmaps, active: _repository.active);
}

@injectable
class AddUserRoadmap {
  final UserRoadmapsRepository _repository;

  AddUserRoadmap(this._repository);

  Future<UserRoadmap> call(String trackId, QuestionLevel level) =>
      _repository.add(trackId, level);
}

@injectable
class SelectUserRoadmap {
  final UserRoadmapsRepository _repository;

  SelectUserRoadmap(this._repository);

  Future<void> call(String roadmapId) => _repository.select(roadmapId);
}

@injectable
class RemoveUserRoadmap {
  final UserRoadmapsRepository _repository;

  RemoveUserRoadmap(this._repository);

  Future<void> call(String roadmapId) => _repository.remove(roadmapId);
}

/// Opens [trackId] in the Roadmaps tab: reuses the learner's roadmap of that
/// track when there is one, otherwise adds it at the suggested level.
@injectable
class OpenTrackRoadmap {
  final UserRoadmapsRepository _repository;
  final SuggestRoadmapLevel _suggestLevel;

  OpenTrackRoadmap(this._repository, this._suggestLevel);

  Future<UserRoadmap> call(String trackId) async {
    for (final roadmap in _repository.roadmaps) {
      if (roadmap.trackId == trackId) {
        await _repository.select(roadmap.id);
        return roadmap;
      }
    }
    return _repository.add(trackId, _suggestLevel());
  }
}

/// Level matching the profile experience; Fresher without a profile.
@injectable
class SuggestRoadmapLevel {
  final ProfileRepository _profileRepository;

  SuggestRoadmapLevel(this._profileRepository);

  QuestionLevel call() => switch (_profileRepository.profile?.experience) {
        ExperienceLevel.junior => QuestionLevel.junior,
        ExperienceLevel.middle => QuestionLevel.middle,
        ExperienceLevel.student ||
        ExperienceLevel.fresher ||
        null =>
          QuestionLevel.fresher,
      };
}
