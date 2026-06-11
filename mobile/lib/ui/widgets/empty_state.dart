import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';

/// Centered empty state with icon, title, and subtitle.
class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    this.sub,
  });

  final IconData icon;
  final String title;
  final String? sub;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: colors.surface2,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: colors.text3, size: 32),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 15.5,
                fontWeight: FontWeight.w700,
                color: colors.text,
              ),
              textAlign: TextAlign.center,
            ),
            if (sub != null) ...[
              const SizedBox(height: 6),
              Text(
                sub!,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w500,
                  color: colors.text3,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
