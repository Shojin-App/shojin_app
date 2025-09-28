import 'package:flutter/material.dart';

import '../utils/app_fonts.dart';

/// Returns a TextStyle for a monospace font.
///
/// Handles the generic 'monospace' family by returning a standard [TextStyle],
/// and uses [AppFonts.getFont] for any other font family with F-Droid compatibility.
TextStyle getMonospaceTextStyle(
  String fontFamily, {
  double? fontSize,
  Color? color,
  FontWeight? fontWeight,
}) {
  if (fontFamily == 'monospace') {
    return TextStyle(
      fontFamily: 'monospace',
      fontSize: fontSize,
      color: color,
      fontWeight: fontWeight,
    );
  }
  // Try Google Fonts first (respects F-Droid settings); if unavailable, fall back to asset/system font family
  try {
    return AppFonts.getFont(
      fontFamily,
      fontSize: fontSize,
      color: color,
      fontWeight: fontWeight,
    );
  } catch (_) {
    return TextStyle(
      fontFamily: fontFamily,
      fontSize: fontSize,
      color: color,
      fontWeight: fontWeight,
    );
  }
}
