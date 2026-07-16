import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:m3e_collection/m3e_collection.dart';
import 'package:shojin_app/screens/atcoder_clans_screen.dart';
import 'package:shojin_app/widgets/shared/app_state_card.dart';

void main() {
  testWidgets('unsupported embedded Clans view offers an external action', (
    tester,
  ) async {
    debugDefaultTargetPlatformOverride = TargetPlatform.windows;
    addTearDown(() => debugDefaultTargetPlatformOverride = null);
    tester.view.physicalSize = const Size(320, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(
            context,
          ).copyWith(textScaler: const TextScaler.linear(1.5)),
          child: child!,
        ),
        home: const AtCoderClansScreen(),
      ),
    );
    await tester.pumpAndSettle();
    debugDefaultTargetPlatformOverride = null;

    expect(find.text('埋め込み表示に対応していません'), findsOneWidget);
    expect(find.text('外部で開く'), findsOneWidget);
    expect(find.text('0%'), findsNothing);
    expect(find.bySemanticsLabel('AtCoder Clansを読み込み中'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('external Clans state stays concise on a wide screen', (
    tester,
  ) async {
    debugDefaultTargetPlatformOverride = TargetPlatform.windows;
    addTearDown(() => debugDefaultTargetPlatformOverride = null);
    tester.view.physicalSize = const Size(1200, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const MaterialApp(home: AtCoderClansScreen()));
    await tester.pumpAndSettle();
    debugDefaultTargetPlatformOverride = null;

    final stateCard = find.byType(AppStateCard);
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
