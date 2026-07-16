import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shojin_app/widgets/shared/web_content_status_header.dart';

void main() {
  testWidgets('web status supports enlarged text on a narrow screen', (
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
        home: const Scaffold(
          body: WebContentStatusHeader(
            statusMessage: 'コードを提出フォームへ自動入力しています',
            detail:
                'C++ 23 (GCC 12.2.0 with an intentionally long name) / 12345文字',
            icon: Icons.cloud_upload_outlined,
            loadingProgress: 72,
            isLoading: true,
            hasError: false,
            progressSemanticsLabel: '提出ページの読み込み進捗',
            onRetry: _noop,
          ),
        ),
      ),
    );

    expect(find.text('72%'), findsOneWidget);
    expect(find.byType(LinearProgressIndicator), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('web error replaces stale progress with a retry action', (
    tester,
  ) async {
    var retried = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: WebContentStatusHeader(
            statusMessage: 'AtCoder Clansを読み込めませんでした',
            detail: '通信状況を確認して再試行してください。',
            icon: Icons.travel_explore,
            loadingProgress: 48,
            isLoading: false,
            hasError: true,
            progressSemanticsLabel: 'AtCoder Clansの読み込み進捗',
            onRetry: () => retried = true,
          ),
        ),
      ),
    );

    expect(find.text('48%'), findsNothing);
    expect(find.byType(LinearProgressIndicator), findsNothing);

    await tester.tap(find.byTooltip('再試行'));
    expect(retried, isTrue);
  });
}

void _noop() {}
