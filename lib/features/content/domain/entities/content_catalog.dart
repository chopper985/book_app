// Package imports:
import 'package:equatable/equatable.dart';

// Project imports:
import 'package:AppName/features/content/domain/entities/question.dart';
import 'package:AppName/features/content/domain/entities/quiz_set.dart';
import 'package:AppName/features/content/domain/entities/track.dart';

/// All bundled content. Kept as lists so the validator can detect duplicates.
class ContentCatalog extends Equatable {
  final List<Track> tracks;
  final List<Question> questions;
  final List<QuizSet> sets;

  ContentCatalog({
    required this.tracks,
    required this.questions,
    required this.sets,
  });

  static final ContentCatalog empty =
      ContentCatalog(tracks: const [], questions: const [], sets: const []);

  late final Map<String, Track> _tracksById = {
    for (final track in tracks) track.id: track,
  };

  late final Map<String, Question> _questionsById = {
    for (final question in questions) question.id: question,
  };

  Track? trackById(String id) => _tracksById[id];

  Question? questionById(String id) => _questionsById[id];

  List<Track> get availableTracks =>
      tracks.where((track) => track.isAvailable).toList()
        ..sort((a, b) => a.order.compareTo(b.order));

  List<QuizSet> setsOfTrack(String trackId) =>
      sets.where((set) => set.trackId == trackId).toList();

  @override
  List<Object?> get props => [tracks, questions, sets];
}
