import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:m3e_collection/m3e_collection.dart';
import 'package:provider/provider.dart';
import 'package:shojin_app/models/contest.dart';
import 'package:shojin_app/providers/contest_provider.dart';
import 'package:shojin_app/screens/upcoming_contests_screen.dart';
import 'package:shojin_app/widgets/shared/app_state_card.dart';

class _FakeContestProvider extends ContestProvider {
  _FakeContestProvider(this.contests, {this.errorMessage});

  final List<Contest> contests;
  final String? errorMessage;
  int upcomingAbcRequestCount = 0;
  int upcomingContestRequestCount = 0;

  @override
  List<Contest> get upcomingABCs => contests;

  @override
  List<Contest> get upcomingContests => contests;

  @override
  bool get isLoading => false;

  @override
  String? get error => errorMessage;

  @override
  Future<void> refreshAll() async {}

  @override
  Future<void> fetchUpcomingABCs() async {
    upcomingAbcRequestCount += 1;
  }

  @override
  Future<void> fetchUpcomingContests() async {
    upcomingContestRequestCount += 1;
  }
}

void main() {
  testWidgets('contest cards support enlarged text on a narrow screen', (
    tester,
  ) async {
    final contest = Contest(
      nameJa: 'AtCoder Beginner Contest 999 長いコンテスト名',
      nameEn: 'AtCoder Beginner Contest 999 Extended Contest Name',
      url: 'https://atcoder.jp/contests/abc999',
      startTime: DateTime(2026, 7, 1, 21),
      durationMin: 100,
      ratedRange: '0 - 1999',
      status: 'Upcoming',
    );
    tester.view.physicalSize = const Size(320, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      ChangeNotifierProvider<ContestProvider>.value(
        value: _FakeContestProvider([contest]),
        child: MaterialApp(
          builder: (context, child) {
            return MediaQuery(
              data: MediaQuery.of(
                context,
              ).copyWith(textScaler: const TextScaler.linear(1.5)),
              child: child!,
            );
          },
          home: const UpcomingContestsScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('ABC'), findsWidgets);
    expect(find.text('開催予定'), findsOneWidget);
    expect(find.text('Upcoming'), findsNothing);
    expect(find.textContaining('長いコンテスト名'), findsOneWidget);
    expect(find.text('レート対象: 0 - 1999'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('contest error state stays concise on a wide screen', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1200, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final provider = _FakeContestProvider(
      const [],
      errorMessage: 'private HTTP exception detail',
    );
    await tester.pumpWidget(
      ChangeNotifierProvider<ContestProvider>.value(
        value: provider,
        child: const MaterialApp(home: UpcomingContestsScreen()),
      ),
    );
    await tester.pumpAndSettle();

    final stateCard = find.byType(AppStateCard);
    expect(stateCard, findsOneWidget);
    expect(tester.getSize(stateCard).width, lessThanOrEqualTo(640));
    expect(find.text('コンテスト情報を取得できませんでした'), findsOneWidget);
    expect(find.text('通信状態を確認して、もう一度お試しください。'), findsOneWidget);
    expect(find.textContaining('private HTTP exception detail'), findsNothing);
    final retryButton = find.ancestor(
      of: find.text('再試行'),
      matching: find.byType(ButtonM3E),
    );
    expect(tester.getSize(retryButton).width, 240);

    await tester.tap(retryButton);
    await tester.pump();

    expect(provider.upcomingAbcRequestCount, 1);
    expect(tester.takeException(), isNull);
  });
}
