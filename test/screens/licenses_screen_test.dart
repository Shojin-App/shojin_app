import 'package:flutter/foundation.dart' show LicenseEntry;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:m3e_collection/m3e_collection.dart';
import 'package:shojin_app/screens/licenses_screen.dart';

void main() {
  testWidgets('license cards support enlarged text on a narrow screen', (
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
        home: const LicensesScreen(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('ライセンス'), findsOneWidget);
    expect(find.byType(ExpansionTile), findsWidgets);
    expect(tester.takeException(), isNull);

    await tester.tap(find.byType(ExpansionTile).first);
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
  });

  testWidgets('standard license error offers a concise retry action', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1000, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    var requestCount = 0;

    Stream<LicenseEntry> failingLicenseStream() async* {
      requestCount += 1;
      await Future<void>.delayed(const Duration(milliseconds: 1));
      throw Exception('private registry detail');
    }

    await tester.pumpWidget(
      MaterialApp(
        home: LicensesScreen(
          standardLicenseStreamBuilder: failingLicenseStream,
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('標準'));
    await tester.pump();
    await tester.pumpAndSettle();

    expect(find.text('標準ライセンスを収集できませんでした。もう一度お試しください。'), findsOneWidget);
    expect(find.textContaining('private registry detail'), findsNothing);
    final retryButton = find.widgetWithText(ButtonM3E, '再試行');
    expect(retryButton, findsOneWidget);
    expect(tester.getSize(retryButton).width, 240);
    final previousRequestCount = requestCount;

    await tester.tap(retryButton);
    await tester.pump();
    await tester.pumpAndSettle();

    expect(requestCount, previousRequestCount + 1);
    expect(tester.takeException(), isNull);
  });
}
