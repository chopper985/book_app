// Dart imports:
import 'dart:io';

// Package imports:
import 'package:flutter_test/flutter_test.dart';

// Project imports:
import 'package:interview_practice/features/content/data/parsers/content_parser.dart';
import 'package:interview_practice/features/content/domain/usecase/validate_content.dart';

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
      parsed.catalog.positions.map((position) => position.id),
      ['mobile', 'frontend', 'backend', 'tester'],
    );
    expect(
      parsed.catalog.availableTracks.map((track) => track.id),
      [
        'flutter',
        'dart',
        'kotlin',
        'swift',
        'react_native',
        'javascript',
        'typescript',
        'react_ts',
        'java',
        'dotnet',
        'python',
        'nodejs',
        'php',
        'go',
        'rust',
        'sql',
        'http_api',
        'git',
        'testing',
      ],
    );
  });
}
