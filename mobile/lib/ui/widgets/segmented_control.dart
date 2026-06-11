import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';

/// Generic segmented control.
class SegmentedControl<T> extends StatelessWidget {
  const SegmentedControl({
    super.key,
    required this.items,
    required this.selected,
    required this.onChanged,
    this.activeColor,
    this.height = 38,
  });

  final List<SegmentItem<T>> items;
  final T selected;
  final ValueChanged<T> onChanged;
  final Color? activeColor;
  final double height;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final ac = activeColor ?? colors.primary;

    return Container(
      height: height,
      decoration: BoxDecoration(
        color: colors.surface2,
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(3),
      child: Row(
        children: items.map((item) {
          final isActive = item.value == selected;
          return Expanded(
            child: GestureDetector(
              onTap: () => onChanged(item.value),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                decoration: BoxDecoration(
                  color: isActive ? ac : Colors.transparent,
                  borderRadius: BorderRadius.circular(9),
                  boxShadow: isActive
                      ? [
                          BoxShadow(
                            color: ac.withValues(alpha: 0.25),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          )
                        ]
                      : null,
                ),
                alignment: Alignment.center,
                child: Text(
                  item.label,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: isActive ? Colors.white : colors.text2,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class SegmentItem<T> {
  const SegmentItem({required this.value, required this.label});
  final T value;
  final String label;
}
