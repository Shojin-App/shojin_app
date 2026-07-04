import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shojin_app/providers/theme_provider.dart';
import 'package:shojin_app/screens/problem_detail_screen.dart';
import 'package:shojin_app/models/problem.dart';
import 'package:shojin_app/services/atcoder_service.dart';
import 'package:shojin_app/widgets/shared/app_state_card.dart';

void main() {
  testWidgets('problem input supports enlarged text on a narrow screen', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    tester.view.physicalSize = const Size(320, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => ThemeProvider(),
        child: MaterialApp(
          builder: (context, child) {
            return MediaQuery(
              data: MediaQuery.of(
                context,
              ).copyWith(textScaler: const TextScaler.linear(1.5)),
              child: child!,
            );
          },
          home: ProblemDetailScreen(onProblemChanged: (_) {}),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('問題詳細'), findsOneWidget);
    expect(find.text('AtCoder問題URL'), findsOneWidget);
    expect(find.text('取得'), findsOneWidget);
    expect(find.byTooltip('URLをクリア'), findsNothing);
    expect(find.byType(AppStateCard), findsOneWidget);
    final urlDecorator = tester.widget<InputDecorator>(
      find.descendant(
        of: find.byType(TextFormField),
        matching: find.byType(InputDecorator),
      ),
    );
    final urlBorder =
        urlDecorator.decoration.enabledBorder! as OutlineInputBorder;
    expect(urlBorder.borderRadius, BorderRadius.circular(8));
    expect(tester.takeException(), isNull);

    await tester.enterText(
      find.byType(TextFormField),
      'https://atcoder.jp/contests/abc001/tasks/abc001_1',
    );
    await tester.pump();

    expect(find.byTooltip('URLをクリア'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('empty problem state stays compact on a wide screen', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    tester.view.physicalSize = const Size(1200, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => ThemeProvider(),
        child: MaterialApp(home: ProblemDetailScreen(onProblemChanged: (_) {})),
      ),
    );
    await tester.pumpAndSettle();

    final emptyState = find.byType(AppStateCard);
    expect(emptyState, findsOneWidget);
    expect(tester.getSize(emptyState).width, lessThanOrEqualTo(640));
    expect(tester.getSize(emptyState).height, lessThan(140));
    expect(tester.takeException(), isNull);
  });

  testWidgets('problem content supports enlarged text on a narrow screen', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    tester.view.physicalSize = const Size(320, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final problem = Problem(
      title: 'A - とても長いタイトルを持つ競技プログラミング問題',
      contestId: 'abc999',
      contestName: 'AtCoder Beginner Contest 999 Extended Name',
      statement: '整数 A と整数 B が与えられます。条件を満たす答えを求めてください。',
      constraints: '1 <= A, B <= 1000000000',
      inputFormat: 'A B',
      outputFormat: '答えを出力してください。',
      samples: [SampleIO(input: '1 2', output: '3', index: 1)],
      url: 'https://atcoder.jp/contests/abc999/tasks/abc999_a',
    );

    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => ThemeProvider(),
        child: MaterialApp(
          builder: (context, child) {
            return MediaQuery(
              data: MediaQuery.of(
                context,
              ).copyWith(textScaler: const TextScaler.linear(1.5)),
              child: child!,
            );
          },
          home: ProblemDetailScreen(
            problemIdToLoad: 'abc999_a',
            atCoderService: _FakeAtCoderService(problem),
            onProblemChanged: (_) {},
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('問題文'), findsOneWidget);
    expect(find.text('入力例 1'), findsOneWidget);
    expect(find.text('出力例 1'), findsOneWidget);
    expect(find.byTooltip('入力例 1をコピー'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}

class _FakeAtCoderService extends AtCoderService {
  _FakeAtCoderService(this.problem);

  final Problem problem;

  @override
  bool isValidAtCoderUrl(String url) => true;

  @override
  Future<Problem> fetchProblem(String url) async => problem;
}
