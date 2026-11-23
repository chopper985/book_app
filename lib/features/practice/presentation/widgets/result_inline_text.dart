// Package imports:
import 'package:material_ui/material_ui.dart';

/// Splits [text] on backticks: `code` parts use [code], the rest [base].
List<InlineSpan> resultInlineSpans(
  String text, {
  required TextStyle base,
  required TextStyle code,
}) {
  final parts = text.split('`');
  return [
    for (var i = 0; i < parts.length; i++)
      if (parts[i].isNotEmpty)
        TextSpan(text: parts[i], style: i.isOdd ? code : base),
  ];
}

/// Fills each `%s` of [template] with a highlighted span from [values].
List<InlineSpan> resultTemplateSpans(
  String template, {
  required TextStyle base,
  required List<(String, TextStyle)> values,
}) {
  final parts = template.split('%s');
  return [
    for (var i = 0; i < parts.length; i++) ...[
      if (parts[i].isNotEmpty) TextSpan(text: parts[i], style: base),
      if (i < parts.length - 1 && i < values.length)
        TextSpan(text: values[i].$1, style: values[i].$2),
    ],
  ];
}
