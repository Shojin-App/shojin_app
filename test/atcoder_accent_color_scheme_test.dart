import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shojin_app/main.dart';

void main() {
  test(
    'AtCoder accent replaces secondary and tertiary Material You colors',
    () {
      const atcoderBrown = Color(0xff804000);
      final base = ColorScheme.fromSeed(
        seedColor: Colors.blue,
        brightness: Brightness.light,
      );
      final expectedFamily = ColorScheme.fromSeed(
        seedColor: atcoderBrown,
        brightness: Brightness.light,
      );

      final result = applyAtCoderAccentColorScheme(base, atcoderBrown);

      expect(result.primary, atcoderBrown);
      expect(result.primaryContainer, atcoderBrown);
      expect(result.secondary, expectedFamily.secondary);
      expect(result.secondaryContainer, expectedFamily.secondaryContainer);
      expect(result.tertiary, expectedFamily.tertiary);
      expect(result.tertiaryContainer, expectedFamily.tertiaryContainer);
      expect(result.secondaryContainer, isNot(base.secondaryContainer));
    },
  );

  test('AtCoder accent derives a dark color family for dark themes', () {
    const atcoderGreen = Color(0xff008000);
    final base = ColorScheme.fromSeed(
      seedColor: Colors.purple,
      brightness: Brightness.dark,
    );
    final expectedFamily = ColorScheme.fromSeed(
      seedColor: atcoderGreen,
      brightness: Brightness.dark,
    );

    final result = applyAtCoderAccentColorScheme(base, atcoderGreen);

    expect(result.brightness, Brightness.dark);
    expect(result.primary, atcoderGreen);
    expect(result.secondaryContainer, expectedFamily.secondaryContainer);
    expect(result.onSecondaryContainer, expectedFamily.onSecondaryContainer);
  });
}
