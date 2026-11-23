// Flutter imports:
import 'package:flutter/services.dart';

// Package imports:
import 'package:material_ui/material_ui.dart';

// Project imports:
import 'package:interview_practice/core/app/colors/app_palette.dart';
import 'package:interview_practice/core/app/languages/data/localization.dart';
import 'package:interview_practice/core/app/themes/data/app_text.dart';
import 'package:interview_practice/core/utils/sizer/design_size.dart';

/// Small caps label above a form control. A [required] field gets a red
/// asterisk; optional fields have no marker.
class FieldLabel extends StatelessWidget {
  final String text;
  final bool required;

  const FieldLabel(this.text, {super.key, this.required = false});

  @override
  Widget build(BuildContext context) {
    final style = AppText.mono(11, height: 16);
    return Padding(
      padding: EdgeInsets.only(bottom: 8.dsp),
      child: Text.rich(
        TextSpan(
          text: text,
          style: style,
          children: [
            if (required)
              TextSpan(
                text: ' *',
                style: style.copyWith(color: AppPalette.error),
              ),
          ],
        ),
      ),
    );
  }
}

/// Text field that owns its controller, so typing never rebuilds it from
/// state. [initial] is read once.
class ProfileTextField extends StatefulWidget {
  final String initial;
  final String? hint;
  final String? errorText;
  final int? maxLength;
  final TextInputType? keyboardType;
  final TextCapitalization textCapitalization;
  final List<TextInputFormatter>? inputFormatters;
  final bool autofocus;
  final ValueChanged<String> onChanged;
  final VoidCallback? onSubmitted;
  final TextInputAction textInputAction;

  const ProfileTextField({
    super.key,
    required this.initial,
    required this.onChanged,
    this.hint,
    this.errorText,
    this.maxLength,
    this.keyboardType,
    this.textCapitalization = TextCapitalization.none,
    this.inputFormatters,
    this.autofocus = false,
    this.onSubmitted,
    this.textInputAction = TextInputAction.next,
  });

  @override
  State<ProfileTextField> createState() => _ProfileTextFieldState();
}

class _ProfileTextFieldState extends State<ProfileTextField> {
  late final TextEditingController _controller =
      TextEditingController(text: widget.initial);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    OutlineInputBorder border(Color color) => OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.dsp),
          borderSide: BorderSide(color: color),
        );
    return TextField(
      controller: _controller,
      autofocus: widget.autofocus,
      maxLength: widget.maxLength,
      keyboardType: widget.keyboardType,
      textCapitalization: widget.textCapitalization,
      inputFormatters: widget.inputFormatters,
      textInputAction: widget.textInputAction,
      style: AppText.sans(16, height: 24),
      cursorColor: AppPalette.primary,
      onChanged: widget.onChanged,
      onSubmitted: (_) => widget.onSubmitted?.call(),
      decoration: InputDecoration(
        hintText: widget.hint,
        hintStyle: AppText.sans(
          16,
          height: 24,
          color: AppPalette.onSurfaceVariant.withValues(alpha: 0.6),
        ),
        errorText: widget.errorText,
        errorStyle: AppText.sans(12, height: 16, color: AppPalette.error),
        counterStyle: AppText.mono(10, height: 14),
        filled: true,
        fillColor: AppPalette.surfaceLow,
        contentPadding: EdgeInsets.symmetric(
          horizontal: 16.dsp,
          vertical: 14.dsp,
        ),
        enabledBorder: border(AppPalette.surfaceHigh),
        focusedBorder: border(AppPalette.primaryStrong),
        errorBorder: border(AppPalette.error),
        focusedErrorBorder: border(AppPalette.error),
      ),
    );
  }
}

/// Button showing a date (or a placeholder) that opens the date picker, with
/// a clear button once set.
class DatePickerField extends StatelessWidget {
  final DateTime? date;
  final String placeholder;
  final DateTime firstDate;
  final DateTime lastDate;
  final DateTime initialDate;
  final ValueChanged<DateTime?> onChanged;

  const DatePickerField({
    super.key,
    required this.date,
    required this.placeholder,
    required this.firstDate,
    required this.lastDate,
    required this.initialDate,
    required this.onChanged,
  });

  Future<void> _pick(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: date ?? initialDate,
      firstDate: firstDate,
      lastDate: lastDate,
    );
    if (picked != null) onChanged(picked);
  }

  @override
  Widget build(BuildContext context) {
    final value = date;
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () => _pick(context),
            style: OutlinedButton.styleFrom(
              minimumSize: Size.fromHeight(48.dsp),
              backgroundColor: AppPalette.surfaceLow,
              side: const BorderSide(color: AppPalette.surfaceHigh),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.dsp),
              ),
              alignment: Alignment.centerLeft,
            ),
            icon: Icon(Icons.event, size: 18.dsp, color: AppPalette.primary),
            label: Text(
              value == null
                  ? placeholder
                  : MaterialLocalizations.of(context).formatMediumDate(value),
              style: AppText.sans(
                14,
                height: 20,
                color: value == null
                    ? AppPalette.onSurfaceVariant
                    : AppPalette.onSurface,
              ),
            ),
          ),
        ),
        if (value != null) ...[
          SizedBox(width: 8.dsp),
          IconButton(
            tooltip: Strings.onboardingClearDate.i18n,
            onPressed: () => onChanged(null),
            icon: Icon(
              Icons.close,
              size: 18.dsp,
              color: AppPalette.onSurfaceVariant,
            ),
          ),
        ],
      ],
    );
  }
}

/// Compact selectable chip for single or multiple choice.
class SelectChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const SelectChip({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(8.dsp);
    return Semantics(
      selected: selected,
      button: true,
      child: Material(
        color: selected ? AppPalette.primaryContainer : AppPalette.surfaceLow,
        shape: RoundedRectangleBorder(
          borderRadius: radius,
          side: BorderSide(
            color: selected ? AppPalette.primaryStrong : AppPalette.surfaceHigh,
          ),
        ),
        child: InkWell(
          borderRadius: radius,
          onTap: onTap,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 12.dsp, vertical: 8.dsp),
            child: Text(
              label,
              style: AppText.sans(
                13,
                height: 18,
                weight: FontWeight.w600,
                color: selected ? AppPalette.primary : AppPalette.onSurface,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
