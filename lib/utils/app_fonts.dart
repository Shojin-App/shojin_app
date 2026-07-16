import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../config/build_config.dart';

/// Font helper to handle F-Droid compatibility
/// For F-Droid builds, uses system fonts instead of online Google Fonts
class AppFonts {
  @visibleForTesting
  static bool forceSystemFontsForTesting = false;

  static bool get _useOnlineFonts =>
      BuildConfig.enableOnlineFonts && !forceSystemFontsForTesting;

  /// Get Noto Sans JP font, with fallback for F-Droid builds
  static TextStyle notoSansJp({
    double? fontSize,
    FontWeight? fontWeight,
    Color? color,
    double? height,
    TextDecoration? decoration,
  }) {
    if (_useOnlineFonts) {
      // Use Google Fonts when online fonts are enabled (non-F-Droid builds)
      return GoogleFonts.notoSansJp(
        fontSize: fontSize,
        fontWeight: fontWeight,
        color: color,
        height: height,
        decoration: decoration,
      );
    } else {
      // Use system font for F-Droid builds
      return TextStyle(
        fontFamily: 'sans-serif', // Android system font
        fontSize: fontSize,
        fontWeight: fontWeight,
        color: color,
        height: height,
        decoration: decoration,
      );
    }
  }

  /// Get the font family name for Noto Sans JP with F-Droid compatibility
  static String? get notoSansJpFontFamily {
    if (_useOnlineFonts) {
      return GoogleFonts.notoSansJp().fontFamily;
    } else {
      return 'sans-serif'; // Android system font
    }
  }

  /// Get any Google Font with fallback for F-Droid builds
  static TextStyle getFont(
    String fontFamily, {
    double? fontSize,
    FontWeight? fontWeight,
    Color? color,
    double? height,
    TextDecoration? decoration,
  }) {
    if (_useOnlineFonts) {
      try {
        return GoogleFonts.getFont(
          fontFamily,
          fontSize: fontSize,
          fontWeight: fontWeight,
          color: color,
          height: height,
          decoration: decoration,
        );
      } catch (e) {
        // Fallback if Google Font is not available
        return TextStyle(
          fontFamily: 'sans-serif',
          fontSize: fontSize,
          fontWeight: fontWeight,
          color: color,
          height: height,
          decoration: decoration,
        );
      }
    } else {
      // Use system font for F-Droid builds
      return TextStyle(
        fontFamily: 'sans-serif',
        fontSize: fontSize,
        fontWeight: fontWeight,
        color: color,
        height: height,
        decoration: decoration,
      );
    }
  }
}
