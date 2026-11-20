// Package imports:
import 'package:injectable/injectable.dart';

// Project imports:
import 'package:interview_practice/core/utils/dio_api/result.dart';
import 'package:interview_practice/features/catalog/domain/entities/position_detail.dart';
import 'package:interview_practice/features/catalog/domain/entities/user_roadmap.dart';
import 'package:interview_practice/features/catalog/domain/repositories/catalog_repository.dart';
import 'package:interview_practice/features/catalog/domain/repositories/user_roadmaps_repository.dart';
import 'package:interview_practice/features/content/domain/entities/position.dart';
import 'package:interview_practice/features/content/domain/entities/question.dart';
import 'package:interview_practice/features/profile/domain/entities/learner_profile.dart';
import 'package:interview_practice/features/profile/domain/repositories/profile_repository.dart';

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

/// Opens [trackId] in the Roadmaps tab: reuses the learner's most recently
/// selected roadmap of that track, otherwise adds it at the suggested level.
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

/// Adds a position roadmap; its icon is the option's main track, or the
/// first core track when the option has none (manual testing).
@injectable
class AddPositionRoadmap {
  final UserRoadmapsRepository _repository;
  final CatalogRepository _catalogRepository;

  AddPositionRoadmap(this._repository, this._catalogRepository);

  Future<UserRoadmap?> call(
    String positionId,
    String optionId,
    QuestionLevel level,
  ) async {
    final positions = (await _catalogRepository.getPositions()).value;
    final position =
        positions?.where((position) => position.id == positionId).firstOrNull;
    final option = position?.optionById(optionId);
    if (position == null || option == null) return null;
    final mainTrackId = position.trackIdsFor(option).firstOrNull;
    if (mainTrackId == null) return null;
    return _repository.addPosition(
      positionId: positionId,
      optionId: optionId,
      mainTrackId: mainTrackId,
      level: level,
    );
  }
}

@injectable
class GetPositions {
  final CatalogRepository _repository;

  GetPositions(this._repository);

  Future<Result<List<Position>>> call() => _repository.getPositions();
}

@injectable
class GetPositionDetail {
  final CatalogRepository _repository;

  GetPositionDetail(this._repository);

  Future<Result<PositionDetail>> call(UserRoadmap roadmap) =>
      _repository.getPositionDetail(
        roadmap.positionId!,
        roadmap.optionId!,
        roadmap.level,
      );
}
