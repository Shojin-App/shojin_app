import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shojin_app/services/settings_service.dart';

void main() {
  testWidgets('clipboard backup restores string lists and explains restart', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final clipboardText = jsonEncode({
      'theme_mode': 'dark',
      'home_widget_order': ['recommendation', 'next_abc', 'clans'],
      'home_hidden_widgets': ['clans'],
    });
    final messenger =
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
    messenger.setMockMethodCallHandler(SystemChannels.platform, (call) async {
      if (call.method == 'Clipboard.getData') {
        return <String, dynamic>{'text': clipboardText};
      }
      return null;
    });
    addTearDown(
      () => messenger.setMockMethodCallHandler(SystemChannels.platform, null),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => TextButton(
              onPressed: () {
                SettingsService(context).importSettingsFromClipboard();
              },
              child: const Text('復元'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('復元'));
    await tester.pumpAndSettle();

    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getString('theme_mode'), 'dark');
    expect(prefs.getStringList('home_widget_order'), [
      'recommendation',
      'next_abc',
      'clans',
    ]);
    expect(prefs.getStringList('home_hidden_widgets'), ['clans']);
    expect(find.text('設定を復元しました。再起動後に反映されます'), findsOneWidget);
  });
}
