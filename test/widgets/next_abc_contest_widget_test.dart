import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shojin_app/models/contest.dart';
import 'package:shojin_app/providers/contest_provider.dart';
import 'package:shojin_app/services/contest_service.dart';
import 'package:shojin_app/widgets/next_abc_contest_widget.dart';

void main() {
  testWidgets('next ABC card supports enlarged text on a narrow screen', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    tester.view.physicalSize = const Size(320, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final contest = Contest(
      nameJa: 'AtCoder Beginner Contest 999 とても長いコンテスト名',
      nameEn: 'AtCoder Beginner Contest 999 with a long English title',
      url: 'https://atcoder.jp/contests/abc999',
      startTime: DateTime(2026, 7, 4, 21),
      durationMin: 100,
      ratedRange: '0 - 1999',
      status: 'Upcoming',
    );

    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) =>
            ContestProvider(contestService: _FakeContestService(contest)),
        child: MaterialApp(
          builder: (context, child) {
            return MediaQuery(
              data: MediaQuery.of(
                context,
              ).copyWith(textScaler: const TextScaler.linear(1.5)),
              child: child!,
            );
          },
          home: const Scaffold(
            body: SingleChildScrollView(child: NextABCContestWidget()),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('次回のABC'), findsOneWidget);
    expect(find.text('ABC'), findsOneWidget);
    expect(find.text('リマインダー: 15分前'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}

class _FakeContestService extends ContestService {
  _FakeContestService(this.contest);

  final Contest contest;

  @override
  Future<Contest?> getNextABC() async => contest;
}
