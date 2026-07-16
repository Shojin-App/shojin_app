import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shojin_app/widgets/shared/app_loading_indicator.dart';

void main() {
  testWidgets('uses a stable default size and announces loading', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(home: Center(child: AppLoadingIndicator())),
    );

    expect(
      tester.getSize(find.byType(AppLoadingIndicator)),
      const Size(40, 40),
    );
    expect(find.bySemanticsLabel('読み込み中'), findsOneWidget);
  });

  testWidgets('supports a context-specific semantics label', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Center(child: AppLoadingIndicator(semanticsLabel: 'コンテストを読み込み中')),
      ),
    );

    expect(find.bySemanticsLabel('コンテストを読み込み中'), findsOneWidget);
  });
}
