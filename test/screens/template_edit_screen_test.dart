import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shojin_app/providers/template_provider.dart';
import 'package:shojin_app/screens/template_edit_screen.dart';

void main() {
  testWidgets('template editor supports enlarged text on a narrow screen', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    tester.view.physicalSize = const Size(320, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => TemplateProvider(),
        child: MaterialApp(
          builder: (context, child) {
            return MediaQuery(
              data: MediaQuery.of(
                context,
              ).copyWith(textScaler: const TextScaler.linear(1.5)),
              child: child!,
            );
          },
          home: const TemplateEditScreen(language: 'Python'),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Pythonのテンプレート編集'), findsOneWidget);
    expect(find.text('保存済みのテンプレート'), findsOneWidget);
    expect(tester.takeException(), isNull);

    await tester.tap(find.byTooltip('デフォルトに戻す'));
    await tester.pumpAndSettle();

    expect(find.text('テンプレートをリセット'), findsOneWidget);
    expect(find.text('キャンセル'), findsOneWidget);
    expect(find.text('リセット'), findsOneWidget);
    expect(tester.takeException(), isNull);

    await tester.tap(find.text('キャンセル'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), 'print("edited")');
    await tester.pump();
    expect(find.text('未保存の変更があります'), findsOneWidget);

    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();

    expect(find.text('変更を破棄しますか？'), findsOneWidget);
    expect(find.text('編集を続ける'), findsOneWidget);
    expect(find.text('破棄'), findsOneWidget);
    expect(tester.takeException(), isNull);

    await tester.tap(find.text('編集を続ける'));
    await tester.pumpAndSettle();

    expect(find.text('変更を破棄しますか？'), findsNothing);
    expect(find.text('未保存の変更があります'), findsOneWidget);
  });
}
