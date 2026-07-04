import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:m3e_collection/m3e_collection.dart';
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
    expect(find.text('実行と提出'), findsOneWidget);
    expect(find.text('サンプル'), findsNothing);
    expect(find.text('提出'), findsNothing);
    expect(find.text('標準入力'), findsOneWidget);
    expect(find.byTooltip('実行結果をコピー'), findsOneWidget);
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
    final narrowRunButton = find.ancestor(
      of: find.text('実行'),
      matching: find.byType(ButtonM3E),
    );
    expect(tester.getSize(narrowRunButton).width, greaterThan(220));
    expect(
      tester
          .widget<IconButton>(
            find.widgetWithIcon(IconButton, Icons.copy_outlined),
          )
          .onPressed,
      isNull,
    );
    expect(tester.takeException(), isNull);

    await tester.tap(find.byTooltip('その他'));
    await tester.pumpAndSettle();

    expect(find.text('コード履歴'), findsOneWidget);
    expect(find.text('コード共有'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('single run action stays compact on a wide screen', (
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

    final runButton = find.ancestor(
      of: find.text('実行'),
      matching: find.byType(ButtonM3E),
    );
    expect(runButton, findsOneWidget);
    expect(find.text('サンプル'), findsNothing);
    expect(find.text('提出'), findsNothing);
    expect(tester.getSize(runButton).width, 220);
    expect(tester.takeException(), isNull);
  });
}
