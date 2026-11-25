// Package imports:
import 'package:equatable/equatable.dart';

// Project imports:
import 'package:interview_practice/features/catalog/domain/entities/track_overview.dart';
import 'package:interview_practice/features/content/domain/entities/position.dart';

/// What a position (Mobile, Front-end, Back-end, Tester) asks for: the
/// languages/platforms to choose from and the shared knowledge.
class RoleTechnologies extends Equatable {
  final Position position;

  /// Tracks of the position's options, in content order.
  final List<TrackOverview> main;

  /// Core tracks every option needs (HTTP, Git, SQL…), minus [main].
  final List<TrackOverview> shared;

  const RoleTechnologies({
    required this.position,
    required this.main,
    required this.shared,
  });

  @override
  List<Object?> get props => [position, main, shared];
}
