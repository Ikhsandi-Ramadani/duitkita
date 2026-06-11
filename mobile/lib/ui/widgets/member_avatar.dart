import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Avatar circle with HSL-based background derived from [hue].
/// bg = hsl(hue 44% 46%), tint variant = hsl(hue 42% 90%).
class MemberAvatar extends StatelessWidget {
  const MemberAvatar({
    super.key,
    required this.hue,
    required this.initial,
    this.size = 40,
    this.tint = false,
    this.ring = false,
    this.ringColor,
    this.ringWidth = 2.5,
  });

  final int hue;
  final String initial;
  final double size;

  /// When true uses the light tint bg (hue 42% 90%) with colored text.
  final bool tint;

  /// Draw an outer ring around the avatar.
  final bool ring;
  final Color? ringColor;
  final double ringWidth;

  @override
  Widget build(BuildContext context) {
    final bg = tint ? _hsl(hue, 0.42, 0.90) : _hsl(hue, 0.44, 0.46);
    final textColor = tint ? _hsl(hue, 0.44, 0.36) : Colors.white;

    Widget avatar = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: bg,
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: Text(
        initial.isNotEmpty ? initial[0].toUpperCase() : '?',
        style: GoogleFonts.plusJakartaSans(
          fontSize: size * 0.42,
          fontWeight: FontWeight.w700,
          color: textColor,
          height: 1,
        ),
      ),
    );

    if (ring) {
      final ringC = ringColor ?? Colors.white;
      avatar = Container(
        width: size + ringWidth * 2 + 2,
        height: size + ringWidth * 2 + 2,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: ringC, width: ringWidth),
        ),
        child: avatar,
      );
    }

    return avatar;
  }

  static Color _hsl(int hue, double s, double l) {
    return HSLColor.fromAHSL(1.0, hue.toDouble(), s, l).toColor();
  }
}
