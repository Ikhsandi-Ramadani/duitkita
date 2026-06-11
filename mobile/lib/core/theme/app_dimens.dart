import 'package:flutter/material.dart';

abstract final class AppRadius {
  static const double sm = 12;
  static const double base = 18;
  static const double lg = 24;
  static const double xl = 30;

  static const borderRadiusSm = BorderRadius.all(Radius.circular(sm));
  static const borderRadiusBase = BorderRadius.all(Radius.circular(base));
  static const borderRadiusLg = BorderRadius.all(Radius.circular(lg));
  static const borderRadiusXl = BorderRadius.all(Radius.circular(xl));
}

abstract final class AppSpacing {
  static const double screenH = 20;
}

abstract final class AppShadows {
  static const sm = [
    BoxShadow(
      color: Color(0x0D14281E),
      offset: Offset(0, 1),
      blurRadius: 2,
    ),
  ];

  static const base = [
    BoxShadow(
      color: Color(0x12142814),
      offset: Offset(0, 4),
      blurRadius: 16,
    ),
  ];

  static const lg = [
    BoxShadow(
      color: Color(0x1F14281E),
      offset: Offset(0, 12),
      blurRadius: 34,
    ),
  ];

  static const primaryShadow = [
    BoxShadow(
      color: Color(0x52047857),
      offset: Offset(0, 8),
      blurRadius: 24,
    ),
  ];
}
