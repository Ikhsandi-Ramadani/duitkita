import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';

/// Small pill badge "Pribadi" or "Bersama".
class ScopeBadge extends StatelessWidget {
  const ScopeBadge({super.key, required this.scope});

  /// 'personal' or 'shared'
  final String scope;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final isShared = scope == 'shared';
    final label = isShared ? 'Bersama' : 'Pribadi';
    final bg = isShared ? colors.primaryTint : colors.surface2;
    final textColor = isShared ? colors.primary : colors.text2;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: GoogleFonts.plusJakartaSans(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: textColor,
          height: 1.2,
        ),
      ),
    );
  }
}
