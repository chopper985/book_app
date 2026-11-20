// Validates bundled content before packaging.
//
// Usage: dart run tool/validate_content.dart [content-root]
// Default root: assets/content. Exits with code 1 when any problem is found.

// Dart imports:
import 'dart:io';

// Project imports:
import 'package:interview_practice/features/content/data/parsers/content_parser.dart';
import 'package:interview_practice/features/content/domain/usecase/validate_content.dart';

Future<void> main(List<String> args) async {
  final root = args.isEmpty ? 'assets/content' : args.first;

  Future<String?> read(String relativePath) async {
    final file = File('$root/$relativePath');
    return file.existsSync() ? file.readAsString() : null;
  }

  final parsed = await const ContentParser().parse(read);
  final issues = [...parsed.issues, ...const ValidateContent()(parsed.catalog)];
  final catalog = parsed.catalog;

  if (issues.isEmpty) {
    stdout.writeln(
      'OK: ${catalog.availableTracks.length} available tracks, '
      '${catalog.questions.length} questions, ${catalog.sets.length} sets.',
    );
    return;
  }

  stderr.writeln('Found ${issues.length} content problem(s):');
  for (final issue in issues) {
    stderr.writeln('  $issue');
  }
  exitCode = 1;
}
