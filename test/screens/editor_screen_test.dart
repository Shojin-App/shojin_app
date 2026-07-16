import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shojin_app/providers/template_provider.dart';
import 'package:shojin_app/providers/theme_provider.dart';
import 'package:shojin_app/screens/editor_screen.dart';

void main() {
  testWidgets('editor controls support enlarged text on a narrow screen', (
    tester,
  ) async {
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
          home: const EditorScreen(problemId: 'default_problem'),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Python'), findsOneWidget);
    expect(find.byKey(const Key('editor-code-area')), findsOneWidget);
    expect(find.byKey(const Key('editor-command-bar')), findsOneWidget);
    expect(find.text('実行'), findsOneWidget);
    expect(find.text('入出力'), findsOneWidget);
    expect(find.text('提出'), findsOneWidget);
    expect(find.text('標準入力'), findsNothing);
    expect(
      tester.getSize(find.byKey(const Key('editor-language-selector'))).height,
      48,
    );
    final languageDropdown = tester.widget<DropdownButton<String>>(
      find.byType(DropdownButton<String>),
    );
    expect(languageDropdown.borderRadius, BorderRadius.circular(8));
    final overflowMenu = tester.widget(
      find.byWidgetPredicate((widget) => widget is PopupMenuButton),
    );
    final overflowShape =
        (overflowMenu as PopupMenuButton).shape! as RoundedRectangleBorder;
    expect(overflowShape.borderRadius, BorderRadius.circular(8));
    expect(
      tester.getSize(find.byKey(const Key('editor-command-bar'))).height,
      lessThanOrEqualTo(80),
    );
    expect(tester.takeException(), isNull);

    await tester.tap(find.text('入出力'));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('editor-io-sheet')), findsOneWidget);
    expect(find.text('標準入力'), findsAtLeastNWidgets(1));
    expect(find.text('実行結果'), findsAtLeastNWidgets(1));
    expect(find.text('サンプル'), findsOneWidget);
    final stdinField = tester.widget<TextField>(
      find.byWidgetPredicate(
        (widget) =>
            widget is TextField &&
            widget.decoration?.hintText == 'プログラムへの入力をここに入力します',
      ),
    );
    expect(stdinField.focusNode?.hasFocus, isFalse);
    expect(tester.takeException(), isNull);

    await tester.tap(find.byTooltip('閉じる'));
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('その他'));
    await tester.pumpAndSettle();

    expect(find.text('コード履歴'), findsOneWidget);
    expect(find.text('コード共有'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('editor command bar stays compact on a wide screen', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    tester.view.physicalSize = const Size(1200, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => ThemeProvider()),
          ChangeNotifierProvider(create: (_) => TemplateProvider()),
        ],
        child: const MaterialApp(
          home: EditorScreen(problemId: 'default_problem'),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('editor-code-area')), findsOneWidget);
    expect(find.text('実行'), findsOneWidget);
    expect(find.text('入出力'), findsOneWidget);
    expect(find.text('提出'), findsOneWidget);
    expect(
      tester.getSize(find.byKey(const Key('editor-command-bar'))).height,
      lessThanOrEqualTo(80),
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('stdin sheet does not replace the code editor', (tester) async {
    SharedPreferences.setMockInitialValues({});
    tester.view.physicalSize = const Size(400, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(() => tester.view.viewInsets = FakeViewPadding.zero);

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => ThemeProvider()),
          ChangeNotifierProvider(create: (_) => TemplateProvider()),
        ],
        child: const MaterialApp(
          // MainScreenがEditorScreenをScaffold内に保持する実機と同じ
          // 構造で、キーボード表示時のオーバーフローを検出する。
          home: Scaffold(body: EditorScreen(problemId: 'default_problem')),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('入出力'));
    await tester.pumpAndSettle();

    final stdinFinder = find.byWidgetPredicate(
      (widget) =>
          widget is TextField &&
          widget.decoration?.hintText == 'プログラムへの入力をここに入力します',
    );
    expect(tester.widget<TextField>(stdinFinder).focusNode?.hasFocus, isFalse);
    await tester.tap(stdinFinder);
    tester.view.viewInsets = const FakeViewPadding(bottom: 300);
    await tester.pump();
    expect(find.byKey(const Key('editor-code-area')), findsOneWidget);
    expect(find.byKey(const Key('editor-command-bar')), findsOneWidget);
    expect(
      tester.getSize(find.byKey(const Key('editor-io-sheet'))).height,
      inInclusiveRange(220, 440),
    );

    tester.view.viewInsets = FakeViewPadding.zero;
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('editor-code-area')), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
