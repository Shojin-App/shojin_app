import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shojin_app/providers/theme_provider.dart';
import 'package:shojin_app/screens/home_screen_new.dart';

void main() {
  testWidgets('shows a recovery action when every home widget is hidden', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({
      'home_widget_order': ['next_abc', 'recommendation', 'clans'],
      'home_hidden_widgets': ['next_abc', 'recommendation', 'clans'],
    });

    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => ThemeProvider(),
        child: const MaterialApp(home: NewHomeScreen()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('表示中のウィジェットはありません'), findsOneWidget);

    final customizeButton = find.text('ホームをカスタマイズ');
    expect(customizeButton, findsOneWidget);
    await tester.tap(customizeButton);
    await tester.pumpAndSettle();

    expect(find.text('非表示'), findsNWidgets(3));
  });
}
