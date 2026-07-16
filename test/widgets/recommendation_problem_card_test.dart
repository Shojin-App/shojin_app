import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shojin_app/widgets/recommendation_problem_card.dart';

void main() {
  testWidgets('problem metadata moves below the title on a narrow screen', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    var tapped = false;
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
          body: RecommendationProblemCard(
            problemId: 'abc999_h',
            title: '非常に長いタイトルを持つおすすめ競技プログラミング問題',
            difficulty: 1200,
            onTap: () => tapped = true,
          ),
        ),
      ),
    );

    final titleBottom = tester
        .getBottomLeft(find.text('非常に長いタイトルを持つおすすめ競技プログラミング問題'))
        .dy;
    final badgeTop = tester.getTopLeft(find.text('1200')).dy;
    expect(badgeTop, greaterThan(titleBottom));
    expect(tester.takeException(), isNull);

    await tester.tap(find.byType(RecommendationProblemCard));
    expect(tapped, isTrue);
  });
}
