import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shojin_app/widgets/shared/app_state_card.dart';

void main() {
  testWidgets('uses the shared card shape and renders optional content', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: AppStateCard(
            icon: Icons.history,
            title: '履歴はまだありません',
            message: 'コードを編集すると履歴が保存されます。',
            child: Text('追加情報'),
          ),
        ),
      ),
    );

    expect(find.text('履歴はまだありません'), findsOneWidget);
    expect(find.text('コードを編集すると履歴が保存されます。'), findsOneWidget);
    expect(find.text('追加情報'), findsOneWidget);

    final card = tester.widget<Card>(find.byType(Card));
    final shape = card.shape! as RoundedRectangleBorder;
    expect(shape.borderRadius, BorderRadius.circular(8));
  });

  testWidgets('uses error container colors for an error state', (tester) async {
    final colorScheme = ColorScheme.fromSeed(seedColor: Colors.blue);

    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(colorScheme: colorScheme),
        home: const Scaffold(
          body: AppStateCard(
            icon: Icons.error_outline,
            title: '読み込みに失敗しました',
            message: '再試行してください。',
            isError: true,
          ),
        ),
      ),
    );

    final icon = tester.widget<Icon>(find.byIcon(Icons.error_outline));
    expect(icon.color, colorScheme.onErrorContainer);
  });
}
