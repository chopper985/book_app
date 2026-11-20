// Package imports:
import 'package:equatable/equatable.dart';

// Project imports:
import 'package:interview_practice/features/content/domain/entities/track.dart';

class TrackOverview extends Equatable {
  final Track track;
  final int setCount;
  final int questionCount;

  const TrackOverview({
    required this.track,
    required this.setCount,
    required this.questionCount,
  });

  @override
  List<Object?> get props => [track, setCount, questionCount];
}
