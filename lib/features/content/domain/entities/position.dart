// Package imports:
import 'package:equatable/equatable.dart';

// Project imports:
import 'package:interview_practice/features/content/domain/entities/localized_text.dart';

/// One way to fill a position, e.g. Mobile via Flutter (+ Dart).
class PositionOption extends Equatable {
  final String id;
  final LocalizedText name;

  /// Main tracks of this option; may be empty (e.g. manual testing).
  final List<String> trackIds;

  const PositionOption({
    required this.id,
    required this.name,
    required this.trackIds,
  });

  @override
  List<Object?> get props => [id, name, trackIds];
}

/// A job position (Mobile, Front-end, Back-end, Tester): the learner picks
/// one option and always studies the shared core tracks.
class Position extends Equatable {
  final String id;
  final LocalizedText name;
  final LocalizedText? description;
  final List<PositionOption> options;

  /// Shared knowledge required whatever the option (SQL, HTTP, Git…).
  final List<String> coreTrackIds;

  const Position({
    required this.id,
    required this.name,
    required this.options,
    required this.coreTrackIds,
    this.description,
  });

  PositionOption? optionById(String id) {
    for (final option in options) {
      if (option.id == id) return option;
    }
    return null;
  }

  /// Option tracks first, then core tracks, without duplicates.
  List<String> trackIdsFor(PositionOption option) =>
      {...option.trackIds, ...coreTrackIds}.toList();

  @override
  List<Object?> get props => [id, name, description, options, coreTrackIds];
}
