// Package imports:
import 'package:equatable/equatable.dart';

// Project imports:
import 'package:interview_practice/features/content/domain/entities/localized_text.dart';

class Topic extends Equatable {
  final String id;
  final LocalizedText name;

  /// Key concepts covered by the topic, e.g. "StatelessWidget vs ...".
  final LocalizedText? description;

  /// Positions (`frontend`, `backend`, `mobile`, `tester`) this topic is
  /// for; empty means every position.
  final List<String> roles;

  const Topic({
    required this.id,
    required this.name,
    this.description,
    this.roles = const [],
  });

  /// Whether the topic belongs to [positionId]'s questions; every topic does
  /// when no position is given.
  bool appliesTo(String? positionId) =>
      positionId == null || roles.isEmpty || roles.contains(positionId);

  @override
  List<Object?> get props => [id, name, description, roles];
}

class Track extends Equatable {
  final String id;
  final LocalizedText name;
  final int order;

  /// Only available tracks have bundled questions and can be practiced.
  final bool isAvailable;
  final List<Topic> topics;

  /// Explore filter group: `mobile`, `frontend`, `backend`, `systems`.
  final String? category;

  /// Short highlight such as "Phổ biến nhất".
  final LocalizedText? badge;

  /// One-line summary of the main topics.
  final LocalizedText? tagline;

  /// Target audience such as "Fresher / Junior".
  final LocalizedText? audience;

  /// Frameworks only: the language tracks it is written in (e.g. JavaScript,
  /// TypeScript); empty for a language track.
  final List<String> languages;

  /// Frameworks only: the runtime track it runs on (e.g. Node.js).
  final String? runtime;

  const Track({
    required this.id,
    required this.name,
    required this.order,
    required this.isAvailable,
    required this.topics,
    this.category,
    this.badge,
    this.tagline,
    this.audience,
    this.languages = const [],
    this.runtime,
  });

  bool get isFramework => languages.isNotEmpty;

  Topic? topicById(String topicId) {
    for (final topic in topics) {
      if (topic.id == topicId) return topic;
    }
    return null;
  }

  @override
  List<Object?> get props => [
        id,
        name,
        order,
        isAvailable,
        topics,
        category,
        badge,
        tagline,
        audience,
        languages,
        runtime,
      ];
}
