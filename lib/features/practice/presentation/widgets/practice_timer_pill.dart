// Dart imports:
import 'dart:async';

// Package imports:
import 'package:material_ui/material_ui.dart';

// Project imports:
import 'package:interview_practice/core/app/colors/app_palette.dart';
import 'package:interview_practice/core/app/themes/data/app_text.dart';
import 'package:interview_practice/core/utils/sizer/design_size.dart';
import 'package:interview_practice/core/utils/widgets/app_svg.dart';
import 'package:interview_practice/gen/assets.gen.dart';

/// Session clock: remaining time of a timed set (calls [onTimeout] once at
/// zero) or elapsed time since [startedAt] when [endsAt] is `null`.
class PracticeTimerPill extends StatefulWidget {
  final DateTime startedAt;
  final DateTime? endsAt;
  final VoidCallback onTimeout;

  const PracticeTimerPill({
    super.key,
    required this.startedAt,
    required this.endsAt,
    required this.onTimeout,
  });

  @override
  State<PracticeTimerPill> createState() => _PracticeTimerPillState();
}

class _PracticeTimerPillState extends State<PracticeTimerPill> {
  late final ValueNotifier<Duration> _value = ValueNotifier(_compute());
  Timer? _timer;
  bool _timedOut = false;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => _tick());
    WidgetsBinding.instance.addPostFrameCallback((_) => _checkTimeout());
  }

  Duration _compute() {
    final now = DateTime.now();
    final endsAt = widget.endsAt;
    if (endsAt == null) return now.difference(widget.startedAt);
    final remaining = endsAt.difference(now);
    return remaining.isNegative ? Duration.zero : remaining;
  }

  void _tick() {
    _value.value = _compute();
    _checkTimeout();
  }

  void _checkTimeout() {
    if (!mounted || _timedOut || widget.endsAt == null) return;
    if (_value.value > Duration.zero) return;
    _timedOut = true;
    _timer?.cancel();
    widget.onTimeout();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _value.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.dsp, vertical: 4.dsp),
      decoration: BoxDecoration(
        color: AppPalette.surfaceContainer,
        borderRadius: BorderRadius.circular(12.dsp),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          AppSvg(
            Assets.figma.practice.icTimer,
            width: 10.5,
            height: 12.25,
          ),
          SizedBox(width: 6.dsp),
          ValueListenableBuilder<Duration>(
            valueListenable: _value,
            builder: (context, value, _) => Text(
              formatClock(value),
              style: AppText.mono(
                10,
                height: 14,
                color: AppPalette.onSurface,
                letterSpacing: -0.25,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// `mm:ss`, or `h:mm:ss` from one hour.
String formatClock(Duration value) {
  String two(int n) => n.toString().padLeft(2, '0');
  final hours = value.inHours;
  final minutes = two(value.inMinutes.remainder(60));
  final seconds = two(value.inSeconds.remainder(60));
  return hours > 0 ? '$hours:$minutes:$seconds' : '$minutes:$seconds';
}
