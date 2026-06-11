import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/utils/format.dart';

/// Displays a monetary amount, respecting the hide-balances flag.
/// When [hidden] is true, shows "••••••" instead of the amount.
class MoneyText extends StatelessWidget {
  const MoneyText({
    super.key,
    required this.amount,
    this.style,
    this.signed = false,
    this.type,
    this.hidden = false,
    this.color,
  });

  final int amount;
  final TextStyle? style;

  /// When true, prefixes with + / − based on [type].
  final bool signed;

  /// Transaction type for signed prefix: 'income' | 'expense' | etc.
  final String? type;

  final bool hidden;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final effectiveStyle = (style ??
            GoogleFonts.plusJakartaSans(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              fontFeatures: const [FontFeature.tabularFigures()],
            ))
        .copyWith(color: color ?? style?.color);

    final text = hidden
        ? '••••••'
        : (signed && type != null ? fmtRpSigned(amount, type!) : fmtRp(amount));

    return Text(text, style: effectiveStyle);
  }
}
