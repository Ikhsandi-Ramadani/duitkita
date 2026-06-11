import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text.dart';

/// Back button + title 24/w800 + optional action widget.
class AppTopBar extends StatelessWidget implements PreferredSizeWidget {
  const AppTopBar({
    super.key,
    required this.title,
    this.action,
    this.onBack,
    this.foregroundColor,
    this.backgroundColor,
    this.titleStyle,
  });

  final String title;
  final Widget? action;
  final VoidCallback? onBack;
  final Color? foregroundColor;
  final Color? backgroundColor;
  final TextStyle? titleStyle;

  @override
  Size get preferredSize => const Size.fromHeight(56);

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final fgColor = foregroundColor ?? colors.text;
    final bgColor = backgroundColor ?? colors.appBg;

    return Container(
      color: bgColor,
      child: SafeArea(
        bottom: false,
        child: SizedBox(
          height: 56,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              children: [
                IconButton(
                  icon: Icon(Icons.arrow_back_ios_new_rounded,
                      color: fgColor, size: 20),
                  onPressed: onBack ?? () => Navigator.of(context).maybePop(),
                  splashRadius: 20,
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    title,
                    style: titleStyle ??
                        AppText.screenTitle(color: fgColor),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                action ?? const SizedBox(width: 48),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
