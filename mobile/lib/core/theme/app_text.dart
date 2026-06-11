import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

abstract final class AppText {
  static TextStyle heroBalance({Color? color}) => GoogleFonts.plusJakartaSans(
        fontSize: 40,
        fontWeight: FontWeight.w800,
        letterSpacing: -0.03 * 40,
        fontFeatures: const [FontFeature.tabularFigures()],
        color: color,
      );

  static TextStyle screenTitle({Color? color}) => GoogleFonts.plusJakartaSans(
        fontSize: 24,
        fontWeight: FontWeight.w800,
        letterSpacing: -0.02 * 24,
        color: color,
      );

  static TextStyle sectionTitle({Color? color}) => GoogleFonts.plusJakartaSans(
        fontSize: 14.5,
        fontWeight: FontWeight.w800,
        color: color,
      );

  static TextStyle cardTitle({Color? color}) => GoogleFonts.plusJakartaSans(
        fontSize: 15.5,
        fontWeight: FontWeight.w700,
        color: color,
      );

  static TextStyle body({Color? color}) => GoogleFonts.plusJakartaSans(
        fontSize: 14.5,
        fontWeight: FontWeight.w500,
        color: color,
      );

  static TextStyle label({Color? color}) => GoogleFonts.plusJakartaSans(
        fontSize: 12.5,
        fontWeight: FontWeight.w600,
        color: color,
      );

  static TextStyle micro({Color? color}) => GoogleFonts.plusJakartaSans(
        fontSize: 11.5,
        fontWeight: FontWeight.w600,
        color: color,
      );

  static TextStyle txAmount({Color? color}) => GoogleFonts.plusJakartaSans(
        fontSize: 15,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.01 * 15,
        fontFeatures: const [FontFeature.tabularFigures()],
        color: color,
      );
}
