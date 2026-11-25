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
    // A framework names its languages and runtime; multi-role tracks keep
    // role-specific topics (DOM is not part of the Back-end questions).
    final next = parsed.catalog.trackById('nextjs')!;
    expect(next.languages, ['javascript', 'typescript']);
    expect(next.runtime, 'nodejs');
    final dom = parsed.catalog.trackById('javascript')!.topicById('dom')!;
    expect(dom.appliesTo('frontend'), isTrue);
    expect(dom.appliesTo('backend'), isFalse);
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
        'nextjs',
        'vue',
        'angular',
        'java',
        'dotnet',
        'python',
        'nodejs',
        'express',
        'nestjs',
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
