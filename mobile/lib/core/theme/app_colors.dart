import 'package:flutter/material.dart';

@immutable
class AppColors extends ThemeExtension<AppColors> {
  const AppColors({
    required this.bg,
    required this.appBg,
    required this.surface,
    required this.surface2,
    required this.surface3,
    required this.text,
    required this.text2,
    required this.text3,
    required this.border,
    required this.border2,
    required this.primary,
    required this.primary600,
    required this.primary700,
    required this.primaryTint,
    required this.primaryTint2,
    required this.onPrimary,
    required this.income,
    required this.incomeTint,
    required this.expense,
    required this.expenseTint,
    required this.transfer,
    required this.transferTint,
    required this.adjust,
    required this.adjustTint,
  });

  final Color bg;
  final Color appBg;
  final Color surface;
  final Color surface2;
  final Color surface3;
  final Color text;
  final Color text2;
  final Color text3;
  final Color border;
  final Color border2;
  final Color primary;
  final Color primary600;
  final Color primary700;
  final Color primaryTint;
  final Color primaryTint2;
  final Color onPrimary;
  final Color income;
  final Color incomeTint;
  final Color expense;
  final Color expenseTint;
  final Color transfer;
  final Color transferTint;
  final Color adjust;
  final Color adjustTint;

  static const light = AppColors(
    bg: Color(0xFFEEF1EF),
    appBg: Color(0xFFF6F8F6),
    surface: Color(0xFFFFFFFF),
    surface2: Color(0xFFF1F4F2),
    surface3: Color(0xFFE8ECE9),
    text: Color(0xFF15201B),
    text2: Color(0xFF5A6B63),
    text3: Color(0xFF8B988F),
    border: Color(0xFFE7EBE8),
    border2: Color(0xFFDDE3DF),
    primary: Color(0xFF047857),
    primary600: Color(0xFF058564),
    primary700: Color(0xFF036249),
    primaryTint: Color(0xFFE6F2ED),
    primaryTint2: Color(0xFFD3E8E0),
    onPrimary: Color(0xFFFFFFFF),
    income: Color(0xFF0E9F6E),
    incomeTint: Color(0xFFE3F5EE),
    expense: Color(0xFFE0603F),
    expenseTint: Color(0xFFFBEAE4),
    transfer: Color(0xFF3B6FD4),
    transferTint: Color(0xFFE6EDFA),
    adjust: Color(0xFF8B7355),
    adjustTint: Color(0xFFF1ECE5),
  );

  static const dark = AppColors(
    bg: Color(0xFF0B110E),
    appBg: Color(0xFF0F1613),
    surface: Color(0xFF18211C),
    surface2: Color(0xFF1F2A24),
    surface3: Color(0xFF26332C),
    text: Color(0xFFE9EFEB),
    text2: Color(0xFF9EB0A7),
    text3: Color(0xFF6C7D75),
    border: Color(0xFF283330),
    border2: Color(0xFF30403A),
    primary: Color(0xFF14B083),
    primary600: Color(0xFF16C091),
    primary700: Color(0xFF0F9D75),
    primaryTint: Color(0xFF11362C),
    primaryTint2: Color(0xFF154437),
    onPrimary: Color(0xFF04211A),
    income: Color(0xFF2DC28D),
    incomeTint: Color(0xFF133229),
    expense: Color(0xFFF0795A),
    expenseTint: Color(0xFF36211B),
    transfer: Color(0xFF5B8DEF),
    transferTint: Color(0xFF1A2840),
    adjust: Color(0xFFC0A786),
    adjustTint: Color(0xFF2C261D),
  );

  @override
  AppColors copyWith({
    Color? bg,
    Color? appBg,
    Color? surface,
    Color? surface2,
    Color? surface3,
    Color? text,
    Color? text2,
    Color? text3,
    Color? border,
    Color? border2,
    Color? primary,
    Color? primary600,
    Color? primary700,
    Color? primaryTint,
    Color? primaryTint2,
    Color? onPrimary,
    Color? income,
    Color? incomeTint,
    Color? expense,
    Color? expenseTint,
    Color? transfer,
    Color? transferTint,
    Color? adjust,
    Color? adjustTint,
  }) {
    return AppColors(
      bg: bg ?? this.bg,
      appBg: appBg ?? this.appBg,
      surface: surface ?? this.surface,
      surface2: surface2 ?? this.surface2,
      surface3: surface3 ?? this.surface3,
      text: text ?? this.text,
      text2: text2 ?? this.text2,
      text3: text3 ?? this.text3,
      border: border ?? this.border,
      border2: border2 ?? this.border2,
      primary: primary ?? this.primary,
      primary600: primary600 ?? this.primary600,
      primary700: primary700 ?? this.primary700,
      primaryTint: primaryTint ?? this.primaryTint,
      primaryTint2: primaryTint2 ?? this.primaryTint2,
      onPrimary: onPrimary ?? this.onPrimary,
      income: income ?? this.income,
      incomeTint: incomeTint ?? this.incomeTint,
      expense: expense ?? this.expense,
      expenseTint: expenseTint ?? this.expenseTint,
      transfer: transfer ?? this.transfer,
      transferTint: transferTint ?? this.transferTint,
      adjust: adjust ?? this.adjust,
      adjustTint: adjustTint ?? this.adjustTint,
    );
  }

  @override
  AppColors lerp(ThemeExtension<AppColors>? other, double t) {
    if (other is! AppColors) return this;
    return AppColors(
      bg: Color.lerp(bg, other.bg, t)!,
      appBg: Color.lerp(appBg, other.appBg, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      surface2: Color.lerp(surface2, other.surface2, t)!,
      surface3: Color.lerp(surface3, other.surface3, t)!,
      text: Color.lerp(text, other.text, t)!,
      text2: Color.lerp(text2, other.text2, t)!,
      text3: Color.lerp(text3, other.text3, t)!,
      border: Color.lerp(border, other.border, t)!,
      border2: Color.lerp(border2, other.border2, t)!,
      primary: Color.lerp(primary, other.primary, t)!,
      primary600: Color.lerp(primary600, other.primary600, t)!,
      primary700: Color.lerp(primary700, other.primary700, t)!,
      primaryTint: Color.lerp(primaryTint, other.primaryTint, t)!,
      primaryTint2: Color.lerp(primaryTint2, other.primaryTint2, t)!,
      onPrimary: Color.lerp(onPrimary, other.onPrimary, t)!,
      income: Color.lerp(income, other.income, t)!,
      incomeTint: Color.lerp(incomeTint, other.incomeTint, t)!,
      expense: Color.lerp(expense, other.expense, t)!,
      expenseTint: Color.lerp(expenseTint, other.expenseTint, t)!,
      transfer: Color.lerp(transfer, other.transfer, t)!,
      transferTint: Color.lerp(transferTint, other.transferTint, t)!,
      adjust: Color.lerp(adjust, other.adjust, t)!,
      adjustTint: Color.lerp(adjustTint, other.adjustTint, t)!,
    );
  }
}

extension AppColorsContext on BuildContext {
  AppColors get appColors =>
      Theme.of(this).extension<AppColors>() ?? AppColors.light;
}
