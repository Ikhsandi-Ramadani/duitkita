import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Small progress ring used on home card.
class ProgressRingSmall extends StatelessWidget {
  const ProgressRingSmall({
    super.key,
    required this.fraction,
    this.size = 42,
    this.strokeWidth = 4,
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
  Widget build(BuildContext context) {
    final c = color ?? Theme.of(context).colorScheme.primary;
    final tc = trackColor ?? c.withValues(alpha: 0.15);

    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _SmallRingPainter(
          fraction: fraction.clamp(0.0, 1.0),
          color: c,
          trackColor: tc,
          strokeWidth: strokeWidth,
        ),
        child: centerWidget != null ? Center(child: centerWidget) : null,
      ),
    );
  }
}

class _SmallRingPainter extends CustomPainter {
  _SmallRingPainter({
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
        -math.pi / 2,
        fraction * 2 * math.pi,
        false,
        fgPaint,
      );
    }
  }

  @override
  bool shouldRepaint(_SmallRingPainter old) =>
      old.fraction != fraction || old.color != color;
}
