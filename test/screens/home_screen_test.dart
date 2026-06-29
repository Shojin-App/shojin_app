import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:m3e_collection/m3e_collection.dart';
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

    final customizeButton = find.text('表示を設定');
    expect(customizeButton, findsOneWidget);
    await tester.tap(customizeButton);
    await tester.pumpAndSettle();

    expect(find.text('非表示'), findsNWidgets(3));
    expect(
      tester.widget<ButtonM3E>(find.widgetWithText(ButtonM3E, '保存')).onPressed,
      isNull,
    );

    final resetButton = find.byTooltip('初期状態に戻す');
    expect(resetButton, findsOneWidget);
    await tester.tap(resetButton);
    await tester.pump();

    expect(find.text('ホームに表示中'), findsNWidgets(3));
    expect(
      tester.widget<ButtonM3E>(find.widgetWithText(ButtonM3E, '保存')).onPressed,
      isNotNull,
    );

    final switches = find.byType(Switch);
    expect(switches, findsNWidgets(3));
    for (var index = 0; index < 2; index++) {
      await tester.tap(switches.at(index));
      await tester.pump();
    }
    expect(find.text('非表示'), findsNWidgets(2));
    expect(find.text('ホームに表示中'), findsOneWidget);

    await tester.tap(find.text('保存'));
    await tester.pumpAndSettle();

    expect(find.text('ホームを更新しました'), findsOneWidget);
    expect(find.text('元に戻す'), findsOneWidget);
  });

  testWidgets('home customizer supports enlarged text on a narrow screen', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({
      'home_widget_order': ['next_abc', 'recommendation', 'clans'],
      'home_hidden_widgets': ['next_abc', 'recommendation', 'clans'],
    });
    tester.view.physicalSize = const Size(320, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => ThemeProvider(),
        child: MaterialApp(
          builder: (context, child) {
            return MediaQuery(
              data: MediaQuery.of(
                context,
              ).copyWith(textScaler: const TextScaler.linear(1.5)),
              child: child!,
            );
          },
          home: const NewHomeScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('ホームをカスタマイズ'));
    await tester.pumpAndSettle();

    expect(find.text('ホームをカスタマイズ'), findsOneWidget);
    expect(find.byType(Switch), findsNWidgets(3));
    expect(tester.takeException(), isNull);
  });
}
