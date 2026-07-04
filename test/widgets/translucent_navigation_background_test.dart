import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shojin_app/widgets/shared/custom_sliver_app_bar.dart';

void main() {
  testWidgets('navigation background becomes fully transparent at zero', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: TranslucentNavigationBackground(
          opacity: 0,
          color: Colors.red,
          child: SizedBox(key: ValueKey('content')),
        ),
      ),
    );

    final background = tester.widget<ColoredBox>(find.byType(ColoredBox).last);
    expect(background.color.a, 0);
    expect(find.byType(BackdropFilter), findsOneWidget);
    expect(find.byKey(const ValueKey('content')), findsOneWidget);
  });

  testWidgets('navigation background applies the requested surface opacity', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: TranslucentNavigationBackground(opacity: 0.5, color: Colors.red),
      ),
    );

    final background = tester.widget<ColoredBox>(find.byType(ColoredBox).last);
    expect(background.color.a, closeTo(0.5, 0.01));
  });
}
