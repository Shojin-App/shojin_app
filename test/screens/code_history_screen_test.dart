import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:m3e_collection/m3e_collection.dart';
import 'package:shojin_app/models/code_history.dart';
import 'package:shojin_app/screens/code_history_screen.dart';
import 'package:shojin_app/services/code_history_service.dart';

class _FakeCodeHistoryService extends CodeHistoryService {
  _FakeCodeHistoryService(this.history);

  final List<CodeHistory> history;

  @override
  Future<List<CodeHistory>> getHistory(String problemId) async => history;
}

class _FailingCodeHistoryService extends CodeHistoryService {
  int requestCount = 0;

  @override
  Future<List<CodeHistory>> getHistory(String problemId) async {
    requestCount += 1;
    await Future<void>.delayed(const Duration(milliseconds: 1));
    throw Exception('private file system detail');
  }
}

void main() {
  testWidgets('code history supports enlarged text on a narrow screen', (
    tester,
  ) async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, (_) async => null);
    addTearDown(
      () => TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(SystemChannels.platform, null),
    );

    final history = CodeHistory(
      id: '1',
      content: 'void main() {\n  print("long code history preview");\n}',
      timestamp: DateTime(2026, 6, 30, 23, 59, 58),
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
        home: CodeHistoryScreen(
          problemId: 'abc999_a',
          codeHistoryService: _FakeCodeHistoryService([history]),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('2026/06/30 23:59:58'), findsOneWidget);
    expect(find.text('3行のコード'), findsOneWidget);
    expect(tester.takeException(), isNull);

    await tester.tap(find.text('2026/06/30 23:59:58'));
    await tester.pumpAndSettle();

    expect(find.text('キャンセル'), findsOneWidget);
    expect(find.text('コピー'), findsOneWidget);
    expect(find.text('復元'), findsOneWidget);
    expect(tester.takeException(), isNull);

    await tester.tap(find.text('コピー'));
    await tester.pump();

    expect(find.text('コードをコピーしました'), findsOneWidget);
  });

  testWidgets('history error offers a concise retry action', (tester) async {
    tester.view.physicalSize = const Size(1000, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final service = _FailingCodeHistoryService();

    await tester.pumpWidget(
      MaterialApp(
        home: CodeHistoryScreen(
          problemId: 'abc999_a',
          codeHistoryService: service,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('保存された履歴を開けませんでした。もう一度お試しください。'), findsOneWidget);
    expect(find.textContaining('private file system detail'), findsNothing);
    final retryButton = find.widgetWithText(ButtonM3E, '再試行');
    expect(retryButton, findsOneWidget);
    expect(tester.getSize(retryButton).width, 240);

    await tester.tap(retryButton);
    // FutureBuilderを新しいFutureへ接続してから、I/O失敗を進める。
    await tester.pump();
    await tester.pumpAndSettle();

    expect(service.requestCount, 2);
    expect(tester.takeException(), isNull);
  });
}
