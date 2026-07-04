import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shojin_app/widgets/shared/responsive_action.dart';

void main() {
  testWidgets('single action fills a narrow layout', (tester) async {
    tester.view.physicalSize = const Size(320, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: ResponsiveAction(
            child: ColoredBox(key: Key('action-child'), color: Colors.blue),
          ),
        ),
      ),
    );

    expect(tester.getSize(find.byKey(const Key('action-child'))).width, 320);
  });

  testWidgets('single action stays compact at the end of a wide layout', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1000, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: ResponsiveAction(
            child: ColoredBox(key: Key('action-child'), color: Colors.blue),
          ),
        ),
      ),
    );

    final action = find.byKey(const Key('action-child'));
    expect(tester.getSize(action).width, 240);
    expect(tester.getTopLeft(action).dx, 760);
  });
}
