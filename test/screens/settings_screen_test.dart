import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:m3e_collection/m3e_collection.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shojin_app/providers/template_provider.dart';
import 'package:shojin_app/providers/theme_provider.dart';
import 'package:shojin_app/screens/settings_screen.dart';

void main() {
  testWidgets('settings remain usable with enlarged text on a narrow screen', (
    tester,
  ) async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, (_) async => null);
    addTearDown(
      () => TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(SystemChannels.platform, null),
    );
    SharedPreferences.setMockInitialValues({});
    tester.view.physicalSize = const Size(320, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => ThemeProvider()),
          ChangeNotifierProvider(create: (_) => TemplateProvider()),
        ],
        child: MaterialApp(
          builder: (context, child) {
            return MediaQuery(
              data: MediaQuery.of(
                context,
              ).copyWith(textScaler: const TextScaler.linear(1.5)),
              child: child!,
            );
          },
          home: const Scaffold(body: SettingsScreen()),
        ),
      ),
    );
    await tester.pump(const Duration(seconds: 1));

    expect(find.text('AtCoder設定'), findsOneWidget);
    expect(find.text('言語設定'), findsNothing);
    expect(find.text('テンプレートをエクスポート'), findsNothing);
    expect(find.text('テンプレートをインポート'), findsNothing);
    final narrowSavedButton = find.ancestor(
      of: find.text('保存済み'),
      matching: find.byType(ButtonM3E),
    );
    expect(tester.getSize(narrowSavedButton).width, greaterThan(200));
    expect(tester.takeException(), isNull);

    await tester.drag(find.byType(CustomScrollView), const Offset(0, -700));
    await tester.pumpAndSettle();

    expect(find.text('エディタ設定'), findsOneWidget);
    final fontDropdown = find.byWidgetPredicate(
      (widget) => widget is DropdownButtonFormField,
    );
    expect(fontDropdown, findsOneWidget);
    final dropdown = tester.widget<DropdownButton<String>>(
      find.descendant(
        of: fontDropdown,
        matching: find.byType(DropdownButton<String>),
      ),
    );
    expect(dropdown.borderRadius, BorderRadius.circular(8));
    expect(tester.takeException(), isNull);

    await tester.scrollUntilVisible(
      find.text('バックアップ'),
      500,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('設定をコピー'), findsOneWidget);
    expect(find.text('設定ファイルを共有'), findsOneWidget);

    await tester.scrollUntilVisible(
      find.text('バージョン'),
      500,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.byTooltip('バージョンをコピー'), findsOneWidget);
    await tester.tap(find.byTooltip('バージョンをコピー'));
    await tester.pump();

    expect(find.text('アプリ情報をすべてコピーしました'), findsOneWidget);
  });

  testWidgets('saved username action stays compact on a wide screen', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({'atcoder_username': 'tourist'});
    tester.view.physicalSize = const Size(1000, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => ThemeProvider()),
          ChangeNotifierProvider(create: (_) => TemplateProvider()),
        ],
        child: const MaterialApp(home: Scaffold(body: SettingsScreen())),
      ),
    );
    await tester.pump(const Duration(seconds: 1));

    final savedButton = find.ancestor(
      of: find.text('保存済み'),
      matching: find.byType(ButtonM3E),
    );
    expect(savedButton, findsOneWidget);
    expect(tester.getSize(savedButton).width, 200);

    await tester.enterText(find.byType(TextField).first, 'new_user');
    await tester.pump();

    expect(find.text('保存済み'), findsNothing);
    expect(find.text('保存'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('technical app information stays collapsed by default', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => ThemeProvider()),
          ChangeNotifierProvider(create: (_) => TemplateProvider()),
        ],
        child: MaterialApp(
          home: Scaffold(
            body: SettingsScreen(
              aboutInfoLoader: () async => {
                'appName': '精進アプリ',
                'packageName': 'io.github.shojinapp.kyopro',
                'buildNumber': '100',
                'platform': 'Android',
                'androidVersion': '15',
                'supportedArch': ['arm64-v8a'],
                'flavor': 'oss',
              },
            ),
          ),
        ),
      ),
    );
    await tester.pump(const Duration(seconds: 1));

    await tester.scrollUntilVisible(
      find.text('詳細情報'),
      500,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pump();

    expect(find.text('端末・パッケージ・ビルド情報'), findsOneWidget);
    expect(find.text('パッケージ名').hitTestable(), findsNothing);

    await tester.tap(find.text('詳細情報'));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.text('パッケージ名'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pump();

    expect(find.text('パッケージ名').hitTestable(), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
