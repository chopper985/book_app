// Package imports:
import 'package:equatable/equatable.dart';

// Project imports:
import 'package:interview_practice/features/content/domain/entities/localized_text.dart';
import 'package:interview_practice/features/content/domain/entities/position.dart';
import 'package:interview_practice/features/content/domain/entities/question.dart';
import 'package:interview_practice/features/content/domain/entities/quiz_set.dart';
import 'package:interview_practice/features/content/domain/entities/track.dart';

/// All bundled content. Kept as lists so the validator can detect duplicates.
class ContentCatalog extends Equatable {
  final List<Track> tracks;
  final List<Question> questions;
  final List<QuizSet> sets;

  /// Job positions built from tracks (Mobile, Front-end, Back-end, Tester).
  final List<Position> positions;

  ContentCatalog({
    required this.tracks,
    required this.questions,
    required this.sets,
    this.positions = const [],
  });

  static final ContentCatalog empty =
      ContentCatalog(tracks: const [], questions: const [], sets: const []);

  Position? positionById(String id) {
    for (final position in positions) {
      if (position.id == id) return position;
    }
    return null;
  }

  static String positionSetId(
    String positionId,
    String optionId,
    QuestionLevel level,
  ) =>
      'position.$positionId.$optionId.${level.name}';

  /// Mock test duration of a position set.
  static const int positionMockMinutes = 30;

  /// Questions drawn from a position set for one mock test.
  static const int positionMockQuestions = 20;

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
  List<QuizSet> setsOfTrack(String trackId) =>
      sets.where((set) => set.trackId == trackId && !set.isGenerated).toList();

  static String topicSetId(
    String trackId,
    String topicId,
    QuestionLevel level,
  ) =>
      '$trackId.topic.$topicId.${level.name}';

  /// Adds generated sets (never authored in `sets.json`):
  /// - one per topic and level with every question of that topic up to the
  ///   level, so "review topic" covers the whole topic even when its
  ///   questions are spread over several authored sets;
  /// - one per position option and level with every question of its tracks
  ///   up to the level, the pool of the position mock test.
  /// Sets with Middle+ questions get the premium plan.
  ContentCatalog withTopicSets() {
    final generated = <QuizSet>[..._positionSets()];
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
              isGenerated: true,
            ),
          );
        }
      }
    }
    return ContentCatalog(
      tracks: tracks,
      questions: questions,
      sets: [...sets, ...generated],
      positions: positions,
    );
  }

  List<QuizSet> _positionSets() {
    final generated = <QuizSet>[];
    for (final position in positions) {
      for (final option in position.options) {
        final trackIds = position.trackIdsFor(option);
        if (trackIds.isEmpty) continue;
        // Only the topics meant for this position (e.g. no DOM questions
        // in a Back-end mock test).
        final pool = [
          for (final trackId in trackIds)
            for (final question in questions)
              if (question.trackId == trackId &&
                  (trackById(trackId)
                          ?.topicById(question.topicId)
                          ?.appliesTo(position.id) ??
                      true))
                question,
        ];
        for (final level in QuestionLevel.values) {
          final included = [
            for (final question in pool)
              if (question.level.index <= level.index) question,
          ];
          if (included.isEmpty) continue;
          final premium = included.any((question) => question.level.isPremium);
          generated.add(
            QuizSet(
              id: positionSetId(position.id, option.id, level),
              // A set belongs to one track: the main one of the option.
              trackId: trackIds.first,
              title: LocalizedText({
                for (final MapEntry(key: language, value: name)
                    in position.name.values.entries)
                  language: language == LocalizedText.defaultLanguage
                      ? 'Thi thử $name · ${option.name.resolve(language)}'
                      : 'Mock test $name · ${option.name.resolve(language)}',
              }),
              questionIds: [for (final question in included) question.id],
              durationMinutes: positionMockMinutes,
              accessPlanId: premium ? premiumPlanId : null,
              isGenerated: true,
            ),
          );
        }
      }
    }
    return generated;
  }

  /// Plan id of Middle/Senior content.
  static const String premiumPlanId = 'premium';

  @override
  List<Object?> get props => [tracks, questions, sets, positions];
}
