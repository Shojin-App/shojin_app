import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shojin_app/main.dart';

void main() {
  test('light theme uses transparent bars with dark Android icons', () {
    final style = appSystemUiOverlayStyle(Brightness.light);

    expect(style.statusBarColor, Colors.transparent);
    expect(style.systemNavigationBarColor, Colors.transparent);
    expect(style.systemNavigationBarDividerColor, Colors.transparent);
    expect(style.statusBarIconBrightness, Brightness.dark);
    expect(style.systemNavigationBarIconBrightness, Brightness.dark);
    expect(style.systemNavigationBarContrastEnforced, isFalse);
  });

  test('dark theme uses transparent bars with light Android icons', () {
    final style = appSystemUiOverlayStyle(Brightness.dark);

    expect(style.statusBarColor, Colors.transparent);
    expect(style.systemNavigationBarColor, Colors.transparent);
    expect(style.statusBarIconBrightness, Brightness.light);
    expect(style.systemNavigationBarIconBrightness, Brightness.light);
    expect(style.systemNavigationBarContrastEnforced, isFalse);
  });
}
