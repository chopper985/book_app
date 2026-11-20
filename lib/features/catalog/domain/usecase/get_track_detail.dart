// Package imports:
import 'package:injectable/injectable.dart';

// Project imports:
import 'package:interview_practice/core/utils/dio_api/result.dart';
import 'package:interview_practice/features/catalog/domain/entities/track_detail.dart';
import 'package:interview_practice/features/catalog/domain/repositories/catalog_repository.dart';
import 'package:interview_practice/features/content/domain/entities/question.dart';

@injectable
class GetTrackDetail {
  final CatalogRepository _repository;

  GetTrackDetail(this._repository);

  Future<Result<TrackDetail>> call(
    String trackId, {
    QuestionLevel? maxLevel,
  }) =>
      _repository.getTrackDetail(trackId, maxLevel: maxLevel);
}
