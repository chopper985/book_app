// Package imports:
import 'package:equatable/equatable.dart';

// Project imports:
import 'package:AppName/features/content/domain/entities/localized_text.dart';
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

  /// Authored sets of the track; generated topic sets are excluded.
  List<QuizSet> setsOfTrack(String trackId) => sets
      .where((set) => set.trackId == trackId && !set.isTopicSet)
      .toList();

  static String topicSetId(
    String trackId,
    String topicId,
    QuestionLevel level,
  ) =>
      '$trackId.topic.$topicId.${level.name}';

  /// Adds one set per topic and level with every question of that topic up to
  /// the level, so "review topic" covers the whole topic even when its
  /// questions are spread over several authored sets. Sets with Middle+
  /// questions keep the premium plan of the content.
  ContentCatalog withTopicSets() {
    final generated = <QuizSet>[];
    for (final track in tracks) {
      for (final topic in track.topics) {
        final topicQuestions = [
          for (final question in questions)
            if (question.trackId == track.id && question.topicId == topic.id)
              question,
        ];
        for (final level in QuestionLevel.values) {
          final included = [
            for (final question in topicQuestions)
              if (question.level.index <= level.index) question,
          ];
          if (included.isEmpty) continue;
          final premium = included.any((question) => question.level.isPremium);
          generated.add(
            QuizSet(
              id: topicSetId(track.id, topic.id, level),
              trackId: track.id,
              title: LocalizedText({
                for (final MapEntry(key: language, value: name)
                    in topic.name.values.entries)
                  language: language == LocalizedText.defaultLanguage
                      ? 'Ôn chủ đề: $name'
                      : 'Topic review: $name',
              }),
              questionIds: [for (final question in included) question.id],
              accessPlanId: premium ? premiumPlanId : null,
              isTopicSet: true,
            ),
          );
        }
      }
    }
    return ContentCatalog(
      tracks: tracks,
      questions: questions,
      sets: [...sets, ...generated],
    );
  }

  /// Plan id of Middle/Senior content.
  static const String premiumPlanId = 'premium';

  @override
  List<Object?> get props => [tracks, questions, sets];
}
