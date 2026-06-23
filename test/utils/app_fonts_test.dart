import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shojin_app/config/build_config.dart';
import 'package:shojin_app/utils/app_fonts.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AppFonts Tests', () {
    setUp(() {
      AppFonts.forceSystemFontsForTesting = true;
    });

    tearDown(() {
      AppFonts.forceSystemFontsForTesting = false;
    });

    test('should allow a deterministic system font path in tests', () {
      expect(BuildConfig.enableOnlineFonts, isA<bool>());
      expect(AppFonts.notoSansJpFontFamily, 'sans-serif');
    });

    test('notoSansJp should preserve TextStyle parameters', () {
      final textStyle = AppFonts.notoSansJp(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: Colors.black,
      );

      expect(textStyle.fontFamily, 'sans-serif');
      expect(textStyle.fontSize, 16);
      expect(textStyle.fontWeight, FontWeight.bold);
      expect(textStyle.color, Colors.black);
    });

    test('getFont should use the forced system font', () {
      final textStyle = AppFonts.getFont(
        'Roboto',
        fontSize: 14,
        fontWeight: FontWeight.normal,
        color: Colors.red,
      );

      expect(textStyle.fontFamily, 'sans-serif');
      expect(textStyle.fontSize, 14);
      expect(textStyle.fontWeight, FontWeight.normal);
      expect(textStyle.color, Colors.red);
    });

    test('should handle null parameters correctly', () {
      final textStyle = AppFonts.notoSansJp();

      expect(textStyle.fontFamily, 'sans-serif');
      expect(textStyle.fontSize, null);
      expect(textStyle.fontWeight, null);
      expect(textStyle.color, null);
    });

    test('should handle all TextStyle parameters', () {
      final textStyle = AppFonts.notoSansJp(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: Colors.blue,
        height: 1.5,
        decoration: TextDecoration.underline,
      );

      expect(textStyle.fontFamily, 'sans-serif');
      expect(textStyle.fontSize, 18);
      expect(textStyle.fontWeight, FontWeight.w600);
      expect(textStyle.color, Colors.blue);
      expect(textStyle.height, 1.5);
      expect(textStyle.decoration, TextDecoration.underline);
    });
  });
}
