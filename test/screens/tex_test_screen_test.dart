import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shojin_app/screens/tex_test_screen.dart';

void main() {
  testWidgets('TeX previews support enlarged text on a narrow screen', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

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
        home: const TexTestScreen(),
      ),
    );
    await tester.pump();

    expect(find.text('TeXレンダリング確認'), findsOneWidget);
    expect(
      tester
          .widgetList<SingleChildScrollView>(find.byType(SingleChildScrollView))
          .any((view) => view.scrollDirection == Axis.horizontal),
      isTrue,
    );
    expect(tester.takeException(), isNull);

    await tester.scrollUntilVisible(
      find.text('コードブロック付き'),
      500,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pump();

    expect(find.text('コードブロック付き'), findsOneWidget);
    expect(find.text('プレビュー'), findsWidgets);
    expect(tester.takeException(), isNull);
  });

  testWidgets('TeX previews keep a readable width on a wide screen', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1200, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const MaterialApp(home: TexTestScreen()));
    await tester.pump();

    final verticalScrollView = tester
        .widgetList<SingleChildScrollView>(find.byType(SingleChildScrollView))
        .singleWhere((view) => view.scrollDirection == Axis.vertical);
    expect(
      verticalScrollView.padding,
      const EdgeInsets.fromLTRB(120, 16, 120, 24),
    );
    expect(tester.takeException(), isNull);
  });
}
