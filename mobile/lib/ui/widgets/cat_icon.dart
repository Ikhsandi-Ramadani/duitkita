import 'package:flutter/material.dart';

/// Rounded chip icon for a transaction category.
/// Light: bg hsl(hue 48% 94%), icon hsl(hue 55% 42%).
/// Dark:  bg hsl(hue 30% 20%), icon hsl(hue 58% 66%).
class CatIcon extends StatelessWidget {
  const CatIcon({
    super.key,
    required this.iconKey,
    required this.hue,
    this.size = 42,
    this.iconSize,
  });

  final String iconKey;
  final int hue;
  final double size;
  final double? iconSize;

  static IconData iconFor(String key) {
    return _iconMap[key] ?? Icons.more_horiz_rounded;
  }

  static const _iconMap = <String, IconData>{
    'utensils': Icons.restaurant_rounded,
    'car': Icons.directions_car_outlined,
    'fuel': Icons.local_gas_station_outlined,
    'receipt': Icons.receipt_long_outlined,
    'signal': Icons.signal_cellular_alt_outlined,
    'bag': Icons.shopping_bag_outlined,
    'health': Icons.favorite_border_rounded,
    'book': Icons.menu_book_outlined,
    'film': Icons.movie_outlined,
    'users': Icons.group_outlined,
    'handheart': Icons.volunteer_activism_outlined,
    'dots': Icons.more_horiz_rounded,
    'briefcase': Icons.work_outline_rounded,
    'gift': Icons.card_giftcard_outlined,
    'shield': Icons.shield_outlined,
    'flag': Icons.flag_outlined,
    'smartphone': Icons.smartphone_outlined,
    'account_balance': Icons.account_balance_outlined,
    'payments': Icons.payments_outlined,
    'account_balance_wallet': Icons.account_balance_wallet_outlined,
    'shopping_cart': Icons.shopping_cart_outlined,
  };

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark
        ? HSLColor.fromAHSL(1.0, hue.toDouble(), 0.30, 0.20).toColor()
        : HSLColor.fromAHSL(1.0, hue.toDouble(), 0.48, 0.94).toColor();
    final iconColor = isDark
        ? HSLColor.fromAHSL(1.0, hue.toDouble(), 0.58, 0.66).toColor()
        : HSLColor.fromAHSL(1.0, hue.toDouble(), 0.55, 0.42).toColor();
    final radius = size * 0.38;
    final iSize = iconSize ?? size * 0.52;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(radius),
      ),
      alignment: Alignment.center,
      child: Icon(
        iconFor(iconKey),
        color: iconColor,
        size: iSize,
      ),
    );
  }
}
