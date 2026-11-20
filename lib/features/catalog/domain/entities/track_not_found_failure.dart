// Project imports:
import 'package:interview_practice/core/error/failure.dart';

class TrackNotFoundFailure extends Failure {
  final String trackId;

  TrackNotFoundFailure(this.trackId);

  @override
  List<Object> get props => [trackId];
}
