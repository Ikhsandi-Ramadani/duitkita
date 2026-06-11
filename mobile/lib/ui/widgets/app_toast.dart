import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';

/// Overlay toast above bottom nav, auto-dismisses after ~2.2s.
class AppToast {
  static OverlayEntry? _current;

  static void show(BuildContext context, String message, {bool success = true}) {
    _current?.remove();
    _current = null;

    final overlay = Overlay.of(context);
    late final OverlayEntry entry;

    entry = OverlayEntry(
      builder: (ctx) => _ToastWidget(
        message: message,
        success: success,
        onDone: () {
          entry.remove();
          if (_current == entry) _current = null;
        },
      ),
    );

    _current = entry;
    overlay.insert(entry);
  }
}

class _ToastWidget extends StatefulWidget {
  const _ToastWidget({
    required this.message,
    required this.success,
    required this.onDone,
  });

  final String message;
  final bool success;
  final VoidCallback onDone;

  @override
  State<_ToastWidget> createState() => _ToastWidgetState();
}

class _ToastWidgetState extends State<_ToastWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _opacity;
  Timer? _dismissTimer;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _opacity = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _ctrl.forward();

    _dismissTimer = Timer(const Duration(milliseconds: 2200), () {
      if (mounted) {
        _ctrl.reverse().then((_) => widget.onDone());
      }
    });
  }

  @override
  void dispose() {
    _dismissTimer?.cancel();
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>() ?? AppColors.light;
    final bg = widget.success ? colors.income : colors.expense;

    return Positioned(
      bottom: 92, // above bottom nav ~76 + margin
      left: 24,
      right: 24,
      child: FadeTransition(
        opacity: _opacity,
        child: Material(
          color: Colors.transparent,
          child: Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: bg.withValues(alpha: 0.35),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                Icon(
                  widget.success ? Icons.check_circle_rounded : Icons.error_rounded,
                  color: Colors.white,
                  size: 18,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    widget.message,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
