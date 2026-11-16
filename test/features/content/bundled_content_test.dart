// Dart imports:
import 'dart:io';

// Package imports:
import 'package:flutter_test/flutter_test.dart';

// Project imports:
import 'package:AppName/features/content/data/parsers/content_parser.dart';
import 'package:AppName/features/content/domain/usecase/validate_content.dart';

void main() {
  test('bundled assets/content is valid', () async {
    final parsed = await const ContentParser().parse((path) async {
      final file = File('assets/content/$path');
      return file.existsSync() ? file.readAsString() : null;
    });
    final issues = [
      ...parsed.issues,
      ...const ValidateContent()(parsed.catalog),
    ];

    expect(issues, isEmpty);
    expect(
      parsed.catalog.availableTracks.map((track) => track.id),
      ['flutter', 'dart'],
    );
  });
}
