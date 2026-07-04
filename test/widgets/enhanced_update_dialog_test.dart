import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shojin_app/services/enhanced_update_service.dart';
import 'package:shojin_app/widgets/update_dialogs.dart';

void main() {
  testWidgets('update dialog supports enlarged text and skip action', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    var skipped = false;

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
          body: Builder(
            builder: (context) => TextButton(
              onPressed: () => showDialog<void>(
                context: context,
                builder: (_) => EnhancedUpdateDialog(
                  updateInfo: EnhancedAppUpdateInfo(
                    version: '2.0.0',
                    releaseTag: 'v2.0.0',
                    releaseNotes: '長いリリースノートです。操作性と安定性を改善しました。',
                    releaseDate: DateTime(2026, 7, 2),
                    fileSize: 25 * 1024 * 1024,
                    fileName: 'shojin-app.apk',
                  ),
                  onSkipPressed: () => skipped = true,
                ),
              ),
              child: const Text('開く'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('開く'));
    await tester.pumpAndSettle();

    expect(find.text('アップデート利用可能'), findsOneWidget);
    expect(find.text('スキップ'), findsOneWidget);
    expect(find.text('更新'), findsOneWidget);
    expect(tester.takeException(), isNull);

    await tester.tap(find.text('スキップ'));
    await tester.pumpAndSettle();
    expect(skipped, isTrue);
    expect(find.text('アップデート利用可能'), findsNothing);
  });
}
