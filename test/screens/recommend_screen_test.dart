import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shojin_app/models/atcoder_rating_info.dart';
import 'package:shojin_app/screens/recommend_screen.dart';
import 'package:shojin_app/services/atcoder_service.dart';
import 'package:shojin_app/widgets/shared/app_state_card.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('recommendation controls fit on a narrow phone screen', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    tester.view.physicalSize = const Size(320, 800);
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
    final lowerField = tester.getRect(
      find.byKey(const Key('recommend-lower-delta')),
    );
    final upperField = tester.getRect(
      find.byKey(const Key('recommend-upper-delta')),
    );
    expect(lowerField.bottom, lessThan(upperField.top));
    expect(tester.takeException(), isNull);
  });

  testWidgets('recommendation layout stays concise on a wide screen', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    tester.view.physicalSize = const Size(1000, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const MaterialApp(home: RecommendScreen()));
    await tester.pumpAndSettle();

    final lowerField = tester.getRect(
      find.byKey(const Key('recommend-lower-delta')),
    );
    final upperField = tester.getRect(
      find.byKey(const Key('recommend-upper-delta')),
    );
    expect(lowerField.top, upperField.top);

    final emptyState = find.byType(AppStateCard);
    expect(emptyState, findsOneWidget);
    expect(tester.getSize(emptyState).width, lessThanOrEqualTo(640));
    expect(tester.takeException(), isNull);
  });

  testWidgets('network errors stay concise and offer retry', (tester) async {
    SharedPreferences.setMockInitialValues({'atcoder_username': 'tourist'});
    tester.view.physicalSize = const Size(320, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final service = _FailingAtCoderService();

    await tester.pumpWidget(
      MaterialApp(
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(
            context,
          ).copyWith(textScaler: const TextScaler.linear(1.5)),
          child: child!,
        ),
        home: RecommendScreen(atCoderService: service),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('通信状態を確認して、もう一度お試しください。'), findsOneWidget);
    expect(find.textContaining('private network detail'), findsNothing);
    expect(find.text('再試行'), findsOneWidget);

    await tester.tap(find.text('再試行'));
    await tester.pumpAndSettle();

    expect(service.requestCount, 2);
    expect(tester.takeException(), isNull);
  });
}

class _FailingAtCoderService extends AtCoderService {
  int requestCount = 0;

  @override
  Future<AtcoderRatingInfo?> fetchAtcoderRatingInfo(String name) async {
    requestCount += 1;
    throw Exception('private network detail');
  }
}
