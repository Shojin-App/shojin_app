import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shojin_app/widgets/shared/copyable_code_section.dart';

void main() {
  testWidgets('code section supports enlarged text and copy feedback', (
    tester,
  ) async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, (_) async => null);
    addTearDown(
      () => TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(SystemChannels.platform, null),
    );
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
        home: const Scaffold(
          body: CopyableCodeSection(
            title: '実際の出力 (stdout)',
            content: '1234567890\nabcdefghijklmnopqrstuvwxyz',
            codeFontFamily: 'monospace',
          ),
        ),
      ),
    );

    expect(tester.takeException(), isNull);
    await tester.tap(find.byTooltip('実際の出力 (stdout)をコピー'));
    await tester.pump();

    expect(find.text('実際の出力 (stdout)をコピーしました'), findsOneWidget);
  });
}
