import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shojin_app/widgets/browser_site_switcher.dart';

void main() {
  testWidgets('site switcher grows for enlarged text on a narrow screen', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    var addPressed = false;
    final scrollController = ScrollController();
    addTearDown(scrollController.dispose);

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
          body: Align(
            alignment: Alignment.topCenter,
            child: BrowserSiteSwitcher(
              scrollController: scrollController,
              siteButtons: const [
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8),
                  child: Center(child: Text('AtCoder Problems')),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8),
                  child: Center(child: Text('AtCoder Clans')),
                ),
              ],
              onAdd: () => addPressed = true,
            ),
          ),
        ),
      ),
    );

    expect(
      tester.getSize(find.byType(BrowserSiteSwitcher)).height,
      greaterThan(72),
    );
    expect(tester.takeException(), isNull);

    await tester.tap(find.byTooltip('サイトを追加'));
    expect(addPressed, isTrue);
  });
}
