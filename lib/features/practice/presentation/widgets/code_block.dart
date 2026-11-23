// Package imports:
import 'package:material_ui/material_ui.dart';

// Project imports:
import 'package:interview_practice/core/app/colors/app_palette.dart';
import 'package:interview_practice/core/app/themes/data/app_text.dart';
import 'package:interview_practice/core/utils/sizer/design_size.dart';
import 'package:interview_practice/features/content/domain/entities/question.dart';

/// IDE-like code window: window bar with file label, line numbers and a
/// light syntax highlight. Long lines scroll horizontally, never wrap.
class CodeBlock extends StatelessWidget {
  final CodeSnippet snippet;

  /// File name without extension shown in the window bar.
  final String fileStem;

  const CodeBlock({super.key, required this.snippet, required this.fileStem});

  @override
  Widget build(BuildContext context) {
    final lines = snippet.source.trimRight().split('\n');
    final codeStyle = AppText.mono(
      12,
      height: 20,
      weight: FontWeight.w400,
      color: AppPalette.onSurface,
    );

    return ClipRRect(
      borderRadius: BorderRadius.circular(8.dsp),
      child: ColoredBox(
        color: AppPalette.surfaceLowest,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _WindowBar(
              fileLabel: '$fileStem.${_extensionOf(snippet.language)}',
              language: snippet.language,
            ),
            Padding(
              padding: EdgeInsets.symmetric(vertical: 16.dsp),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.only(left: 16.dsp, right: 16.dsp),
                    child: Text(
                      List.generate(lines.length, (i) => '${i + 1}').join('\n'),
                      textAlign: TextAlign.right,
                      softWrap: false,
                      style: codeStyle.copyWith(
                        color:
                            AppPalette.onSurfaceVariant.withValues(alpha: 0.4),
                      ),
                    ),
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      padding: EdgeInsets.only(right: 16.dsp),
                      child: Text.rich(
                        TextSpan(
                          style: codeStyle,
                          children: highlightCode(lines.join('\n')),
                        ),
                        softWrap: false,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  static String _extensionOf(String language) {
    final key = language.toLowerCase();
    return _extensions[key] ?? key;
  }

  static const Map<String, String> _extensions = {
    'typescript': 'ts',
    'javascript': 'js',
    'rust': 'rs',
    'csharp': 'cs',
    'c#': 'cs',
    'kotlin': 'kt',
    'python': 'py',
    'swift': 'swift',
    'java': 'java',
    'go': 'go',
    'tsx': 'tsx',
  };
}

class _WindowBar extends StatelessWidget {
  final String fileLabel;
  final String language;

  const _WindowBar({required this.fileLabel, required this.language});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppPalette.surfaceLow,
      padding: EdgeInsets.symmetric(horizontal: 16.dsp, vertical: 10.dsp),
      child: Row(
        children: [
          for (final color in _dots) ...[
            Container(
              width: 10.dsp,
              height: 10.dsp,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
            SizedBox(width: 6.dsp),
          ],
          SizedBox(width: 6.dsp),
          Flexible(
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: 8.dsp,
                vertical: 2.dsp,
              ),
              decoration: BoxDecoration(
                color: AppPalette.surfaceHigh,
                borderRadius: BorderRadius.circular(4.dsp),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.code,
                    size: 12.dsp,
                    color: AppPalette.onSurfaceVariant,
                  ),
                  SizedBox(width: 6.dsp),
                  Flexible(
                    child: Text(
                      fileLabel,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppText.mono(
                        11,
                        height: 16,
                        weight: FontWeight.w500,
                        color: AppPalette.onSurface,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const Spacer(),
          SizedBox(width: 8.dsp),
          Text(
            language.toUpperCase(),
            style: AppText.mono(10, height: 14, letterSpacing: 0.5),
          ),
        ],
      ),
    );
  }

  static const List<Color> _dots = [
    Color(0xFFFF5F56),
    Color(0xFFFFBD2E),
    Color(0xFF27C93F),
  ];
}

// Syntax colors of the code window.
const Color _keywordColor = AppPalette.purple;
const Color _stringColor = Color(0xFFA6E3A1);
const Color _commentColor = Color(0xFF6B7681);
const Color _numberColor = Color(0xFFFFB68D);
const Color _typeColor = AppPalette.teal;
const Color _functionColor = AppPalette.primary;

final RegExp _tokenPattern = RegExp(
  r'(//[^\n]*|/\*[\s\S]*?\*/)'
  r'''|('(?:[^'\\\n]|\\.)*'|"(?:[^"\\\n]|\\.)*")'''
  r'|(@\w+)'
  r'|\b(\d+(?:\.\d+)?)\b'
  r'|\b([A-Za-z_$][\w$]*)\b',
);

const Set<String> _keywords = {
  'abstract',
  'actor',
  'as',
  'async',
  'await',
  'break',
  'case',
  'catch',
  'chan',
  'class',
  'const',
  'continue',
  'default',
  'defer',
  'deinit',
  'delete',
  'do',
  'elif',
  'else',
  'enum',
  'export',
  'extends',
  'extension',
  'false',
  'fileprivate',
  'final',
  'finally',
  'fn',
  'for',
  'from',
  'fun',
  'func',
  'function',
  'get',
  'go',
  'guard',
  'if',
  'impl',
  'implements',
  'import',
  'in',
  'init',
  'inout',
  'instanceof',
  'interface',
  'internal',
  'is',
  'late',
  'lateinit',
  'let',
  'loop',
  'match',
  'mixin',
  'mod',
  'mut',
  'namespace',
  'new',
  'nil',
  'null',
  'object',
  'override',
  'package',
  'private',
  'protected',
  'protocol',
  'pub',
  'public',
  'readonly',
  'record',
  'required',
  'return',
  'sealed',
  'select',
  'Self',
  'self',
  'set',
  'static',
  'struct',
  'super',
  'switch',
  'this',
  'throw',
  'throws',
  'trait',
  'true',
  'try',
  'type',
  'typeof',
  'undefined',
  'unowned',
  'unsafe',
  'use',
  'using',
  'val',
  'var',
  'virtual',
  'void',
  'weak',
  'where',
  'while',
  'with',
  'yield',
};

/// Splits [source] into colored spans. A simple regex tokenizer: comments,
/// strings, annotations, numbers, keywords, types and function calls.
List<TextSpan> highlightCode(String source) {
  final spans = <TextSpan>[];
  var cursor = 0;
  for (final match in _tokenPattern.allMatches(source)) {
    if (match.start > cursor) {
      spans.add(TextSpan(text: source.substring(cursor, match.start)));
    }
    final text = match.group(0)!;
    spans.add(TextSpan(text: text, style: _styleOf(match, source)));
    cursor = match.end;
  }
  if (cursor < source.length) {
    spans.add(TextSpan(text: source.substring(cursor)));
  }
  return spans;
}

TextStyle? _styleOf(RegExpMatch match, String source) {
  if (match.group(1) != null) {
    return const TextStyle(color: _commentColor, fontStyle: FontStyle.italic);
  }
  if (match.group(2) != null) return const TextStyle(color: _stringColor);
  if (match.group(3) != null) return const TextStyle(color: _keywordColor);
  if (match.group(4) != null) return const TextStyle(color: _numberColor);

  final word = match.group(5)!;
  if (_keywords.contains(word)) return const TextStyle(color: _keywordColor);
  if (match.end < source.length && source[match.end] == '(') {
    return const TextStyle(color: _functionColor);
  }
  final first = word[0];
  if (first.toUpperCase() == first && first != '_' && first != r'$') {
    return const TextStyle(color: _typeColor);
  }
  return null;
}
