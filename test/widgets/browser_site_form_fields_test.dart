import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shojin_app/widgets/browser_site_form_fields.dart';

void main() {
  testWidgets('site form shows field errors with enlarged text', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final titleController = TextEditingController();
    final urlController = TextEditingController();
    addTearDown(titleController.dispose);
    addTearDown(urlController.dispose);
    var changedTitle = '';
    var changedUrl = '';

    await tester.pumpWidget(
      MaterialApp(
        builder: (context, child) {
          return MediaQuery(
            data: MediaQuery.of(
              context,
            ).copyWith(textScaler: const TextScaler.linear(1.5)),
            child: child!,
          );
        },
        home: Scaffold(
          body: BrowserSiteFormFields(
            titleController: titleController,
            urlController: urlController,
            titleErrorText: 'タイトルを入力してください',
            urlErrorText: '有効なURLを入力してください',
            onTitleChanged: (value) => changedTitle = value,
            onUrlChanged: (value) => changedUrl = value,
          ),
        ),
      ),
    );

    expect(find.text('タイトルを入力してください'), findsOneWidget);
    expect(find.text('有効なURLを入力してください'), findsOneWidget);
    final titleField = tester.widget<TextField>(find.byType(TextField).first);
    final titleBorder =
        titleField.decoration!.enabledBorder! as OutlineInputBorder;
    expect(titleBorder.borderRadius, BorderRadius.circular(8));
    expect(tester.takeException(), isNull);

    await tester.enterText(find.byType(TextField).first, 'AtCoder');
    await tester.enterText(find.byType(TextField).last, 'https://atcoder.jp');
    expect(changedTitle, 'AtCoder');
    expect(changedUrl, 'https://atcoder.jp');
  });
}
