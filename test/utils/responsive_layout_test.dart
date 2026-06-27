import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shojin_app/utils/responsive_layout.dart';

void main() {
  Future<double> horizontalPaddingFor(WidgetTester tester, double width) async {
    late double padding;
    await tester.pumpWidget(
      MediaQuery(
        data: MediaQueryData(size: Size(width, 800)),
        child: Directionality(
          textDirection: TextDirection.ltr,
          child: Builder(
            builder: (context) {
              padding = ResponsiveLayout.horizontalPadding(context);
              return const SizedBox.shrink();
            },
          ),
        ),
      ),
    );
    return padding;
  }

  testWidgets('centers 960px content on a wide viewport', (tester) async {
    expect(await horizontalPaddingFor(tester, 1280), 160);
  });

  testWidgets('keeps minimum page padding on a narrow viewport', (
    tester,
  ) async {
    expect(await horizontalPaddingFor(tester, 390), 16);
  });

  testWidgets('adds the system bottom inset to list padding', (tester) async {
    late EdgeInsets padding;
    await tester.pumpWidget(
      MediaQuery(
        data: const MediaQueryData(
          size: Size(390, 800),
          viewPadding: EdgeInsets.only(bottom: 24),
        ),
        child: Directionality(
          textDirection: TextDirection.ltr,
          child: Builder(
            builder: (context) {
              padding = ResponsiveLayout.listPadding(context);
              return const SizedBox.shrink();
            },
          ),
        ),
      ),
    );

    expect(padding.bottom, 48);
  });
}
