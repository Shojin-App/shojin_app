import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:m3e_collection/m3e_collection.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shojin_app/providers/theme_provider.dart';
import 'package:shojin_app/screens/browser_screen.dart';

void main() {
  testWidgets('unsupported embedded browser shows an external-open state', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    debugDefaultTargetPlatformOverride = TargetPlatform.windows;
    addTearDown(() => debugDefaultTargetPlatformOverride = null);
    tester.view.physicalSize = const Size(320, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => ThemeProvider(),
        child: MaterialApp(
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(
              context,
            ).copyWith(textScaler: const TextScaler.linear(1.5)),
            child: child!,
          ),
          home: BrowserScreen(navigateToProblem: (_) {}),
        ),
      ),
    );
    await tester.pumpAndSettle();
    debugDefaultTargetPlatformOverride = null;

    expect(find.text('埋め込み表示に対応していません'), findsOneWidget);
    expect(find.text('外部で開く'), findsOneWidget);
    expect(find.bySemanticsLabel('ブラウザを準備中'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('external-open state keeps a readable width on desktop', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    debugDefaultTargetPlatformOverride = TargetPlatform.windows;
    addTearDown(() => debugDefaultTargetPlatformOverride = null);
    tester.view.physicalSize = const Size(1200, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => ThemeProvider(),
        child: MaterialApp(home: BrowserScreen(navigateToProblem: (_) {})),
      ),
    );
    await tester.pumpAndSettle();
    debugDefaultTargetPlatformOverride = null;

    final stateCard = find.ancestor(
      of: find.text('埋め込み表示に対応していません'),
      matching: find.byType(Card),
    );
    expect(stateCard, findsOneWidget);
    expect(tester.getSize(stateCard).width, lessThanOrEqualTo(640));
    final externalButton = find.ancestor(
      of: find.text('外部で開く'),
      matching: find.byType(ButtonM3E),
    );
    expect(tester.getSize(externalButton).width, 240);
    expect(tester.takeException(), isNull);
  });
}
