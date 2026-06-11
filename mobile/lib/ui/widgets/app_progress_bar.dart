import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Animated progress bar — width animates over 600ms.
/// Shows [expenseColor] when [fraction] > 1.0 (over budget).
class AppProgressBar extends StatefulWidget {
  const AppProgressBar({
    super.key,
    required this.fraction,
    this.height = 6,
    this.normalColor,
    this.overColor,
    this.trackColor,
    this.radius = 3,
  });

  final double fraction;
  final double height;
  final Color? normalColor;
  final Color? overColor;
  final Color? trackColor;
  final double radius;

  @override
  State<AppProgressBar> createState() => _AppProgressBarState();
}

class _AppProgressBarState extends State<AppProgressBar>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _anim = Tween<double>(begin: 0, end: widget.fraction.clamp(0, 1))
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
    if (!MediaQuery.of(context).disableAnimations) {
      _ctrl.forward();
    } else {
      _ctrl.value = 1;
    }
  }

  @override
  void didUpdateWidget(AppProgressBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.fraction != widget.fraction) {
      _anim = Tween<double>(
        begin: _anim.value,
        end: widget.fraction.clamp(0, 1),
      ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
      _ctrl
        ..reset()
        ..forward();
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isOver = widget.fraction > 1.0;
    final barColor = isOver
        ? (widget.overColor ?? Theme.of(context).colorScheme.error)
        : (widget.normalColor ?? Theme.of(context).colorScheme.primary);
    final trackColor = widget.trackColor ??
        barColor.withValues(alpha: 0.15);

    return AnimatedBuilder(
      animation: _anim,
      builder: (context, _) {
        return LayoutBuilder(
          builder: (context, constraints) {
            final maxWidth = constraints.maxWidth;
            final barWidth = maxWidth * math.min(_anim.value, 1.0);
            return Container(
              height: widget.height,
              width: double.infinity,
              decoration: BoxDecoration(
                color: trackColor,
                borderRadius: BorderRadius.circular(widget.radius),
              ),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Container(
                  height: widget.height,
                  width: barWidth,
                  decoration: BoxDecoration(
                    color: barColor,
                    borderRadius: BorderRadius.circular(widget.radius),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}

/// Circular progress ring using CustomPainter.
class ProgressRing extends StatefulWidget {
  const ProgressRing({
    super.key,
    required this.fraction,
    this.size = 56,
    this.strokeWidth = 5,
    this.color,
    this.trackColor,
    this.centerWidget,
  });

  final double fraction;
  final double size;
  final double strokeWidth;
  final Color? color;
  final Color? trackColor;
  final Widget? centerWidget;

  @override
  State<ProgressRing> createState() => _ProgressRingState();
}

class _ProgressRingState extends State<ProgressRing>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _anim = Tween<double>(begin: 0, end: widget.fraction.clamp(0, 1))
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.color ?? Theme.of(context).colorScheme.primary;
    final trackColor = widget.trackColor ?? color.withValues(alpha: 0.15);

    return AnimatedBuilder(
      animation: _anim,
      builder: (ctx, _) {
        return SizedBox(
          width: widget.size,
          height: widget.size,
          child: CustomPaint(
            painter: _RingPainter(
              fraction: _anim.value,
              color: color,
              trackColor: trackColor,
              strokeWidth: widget.strokeWidth,
            ),
            child: widget.centerWidget != null
                ? Center(child: widget.centerWidget)
                : null,
          ),
        );
      },
    );
  }
}

class _RingPainter extends CustomPainter {
  _RingPainter({
    required this.fraction,
    required this.color,
    required this.trackColor,
    required this.strokeWidth,
  });

  final double fraction;
  final Color color;
  final Color trackColor;
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;
    const startAngle = -math.pi / 2;

    final trackPaint = Paint()
      ..color = trackColor
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final fgPaint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, trackPaint);
    if (fraction > 0) {
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        fraction * 2 * math.pi,
        false,
        fgPaint,
      );
    }
  }

  @override
  bool shouldRepaint(_RingPainter old) =>
      old.fraction != fraction || old.color != color;
}
