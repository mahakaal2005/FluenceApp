import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Centralized text styles using Inter font family.
/// All text styles used throughout the app should be defined here.
class AppTextStyles {
  // Private constructor to prevent instantiation
  AppTextStyles._();

  // Base font family - Inter
  static const String fontFamily = 'Inter';

  /// Get Inter text style with custom properties
  static TextStyle inter({
    double? fontSize,
    FontWeight? fontWeight,
    Color? color,
    double? height,
    double? letterSpacing,
  }) {
    return GoogleFonts.inter(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      height: height,
      letterSpacing: letterSpacing,
    );
  }

  // Display styles (largest text)
  static TextStyle displayLarge({
    Color? color,
  }) {
    return GoogleFonts.inter(
      fontSize: 57,
      fontWeight: FontWeight.w400,
      letterSpacing: -0.25,
      color: color,
      height: 1.12,
    );
  }

  static TextStyle displayMedium({
    Color? color,
  }) {
    return GoogleFonts.inter(
      fontSize: 45,
      fontWeight: FontWeight.w400,
      letterSpacing: 0,
      color: color,
      height: 1.16,
    );
  }

  static TextStyle displaySmall({
    Color? color,
  }) {
    return GoogleFonts.inter(
      fontSize: 36,
      fontWeight: FontWeight.w400,
      letterSpacing: 0,
      color: color,
      height: 1.22,
    );
  }

  // Headline styles
  static TextStyle headlineLarge({
    Color? color,
  }) {
    return GoogleFonts.inter(
      fontSize: 32,
      fontWeight: FontWeight.w400,
      letterSpacing: 0,
      color: color,
      height: 1.25,
    );
  }

  static TextStyle headlineMedium({
    Color? color,
  }) {
    return GoogleFonts.inter(
      fontSize: 28,
      fontWeight: FontWeight.w400,
      letterSpacing: 0,
      color: color,
      height: 1.29,
    );
  }

  static TextStyle headlineSmall({
    Color? color,
  }) {
    return GoogleFonts.inter(
      fontSize: 24,
      fontWeight: FontWeight.w400,
      letterSpacing: 0,
      color: color,
      height: 1.33,
    );
  }

  // Title styles
  static TextStyle titleLarge({
    Color? color,
  }) {
    return GoogleFonts.inter(
      fontSize: 22,
      fontWeight: FontWeight.w400,
      letterSpacing: 0,
      color: color,
      height: 1.27,
    );
  }

  static TextStyle titleMedium({
    Color? color,
  }) {
    return GoogleFonts.inter(
      fontSize: 16,
      fontWeight: FontWeight.w500,
      letterSpacing: 0.15,
      color: color,
      height: 1.50,
    );
  }

  static TextStyle titleSmall({
    Color? color,
  }) {
    return GoogleFonts.inter(
      fontSize: 14,
      fontWeight: FontWeight.w500,
      letterSpacing: 0.1,
      color: color,
      height: 1.43,
    );
  }

  // Body styles
  static TextStyle bodyLarge({
    Color? color,
  }) {
    return GoogleFonts.inter(
      fontSize: 16,
      fontWeight: FontWeight.w400,
      letterSpacing: 0.15,
      color: color,
      height: 1.50,
    );
  }

  static TextStyle bodyMedium({
    Color? color,
  }) {
    return GoogleFonts.inter(
      fontSize: 14,
      fontWeight: FontWeight.w400,
      letterSpacing: 0.25,
      color: color,
      height: 1.43,
    );
  }

  static TextStyle bodySmall({
    Color? color,
  }) {
    return GoogleFonts.inter(
      fontSize: 12,
      fontWeight: FontWeight.w400,
      letterSpacing: 0.4,
      color: color,
      height: 1.33,
    );
  }

  // Label styles
  static TextStyle labelLarge({
    Color? color,
  }) {
    return GoogleFonts.inter(
      fontSize: 14,
      fontWeight: FontWeight.w500,
      letterSpacing: 0.1,
      color: color,
      height: 1.43,
    );
  }

  static TextStyle labelMedium({
    Color? color,
  }) {
    return GoogleFonts.inter(
      fontSize: 12,
      fontWeight: FontWeight.w500,
      letterSpacing: 0.5,
      color: color,
      height: 1.33,
    );
  }

  static TextStyle labelSmall({
    Color? color,
  }) {
    return GoogleFonts.inter(
      fontSize: 11,
      fontWeight: FontWeight.w500,
      letterSpacing: 0.5,
      color: color,
      height: 1.45,
    );
  }
}

