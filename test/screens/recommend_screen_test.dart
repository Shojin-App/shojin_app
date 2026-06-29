import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shojin_app/screens/recommend_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('recommendation controls fit on a narrow phone screen', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const MaterialApp(home: RecommendScreen()));
    await tester.pumpAndSettle();

    expect(find.text('下限差'), findsOneWidget);
    expect(find.text('上限差'), findsOneWidget);
    expect(find.text('おすすめを取得'), findsOneWidget);
    expect(find.text('条件を適用'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('recommendation controls support enlarged text', (tester) async {
    SharedPreferences.setMockInitialValues({});
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
        home: const RecommendScreen(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('おすすめを取得'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
