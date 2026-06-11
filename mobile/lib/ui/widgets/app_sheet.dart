import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

/// Bottom sheet with slide-up animation (.34s), radius top 24, handle bar.
class AppSheet {
  static Future<T?> show<T>({
    required BuildContext context,
    required Widget child,
    bool isScrollControlled = true,
    bool isDismissible = true,
    double? maxHeightFraction,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      isScrollControlled: isScrollControlled,
      isDismissible: isDismissible,
      backgroundColor: Colors.transparent,
      transitionAnimationController: AnimationController(
        vsync: Navigator.of(context),
        duration: const Duration(milliseconds: 340),
      ),
      builder: (ctx) => _SheetContent(
        maxHeightFraction: maxHeightFraction ?? 0.92,
        child: child,
      ),
    );
  }
}

class _SheetContent extends StatelessWidget {
  const _SheetContent({required this.child, required this.maxHeightFraction});

  final Widget child;
  final double maxHeightFraction;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final maxHeight =
        MediaQuery.of(context).size.height * maxHeightFraction;

    return ConstrainedBox(
      constraints: BoxConstraints(maxHeight: maxHeight),
      child: Container(
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(24),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),
            Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: colors.border2,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Flexible(child: child),
          ],
        ),
      ),
    );
  }
}
