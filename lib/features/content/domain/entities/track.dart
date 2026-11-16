// Package imports:
import 'package:equatable/equatable.dart';

// Project imports:
import 'package:AppName/features/content/domain/entities/localized_text.dart';

class Topic extends Equatable {
  final String id;
  final LocalizedText name;

  /// Key concepts covered by the topic, e.g. "StatelessWidget vs ...".
  final LocalizedText? description;

  const Topic({required this.id, required this.name, this.description});

  @override
  List<Object?> get props => [id, name, description];
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
  });

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
      ];
}
