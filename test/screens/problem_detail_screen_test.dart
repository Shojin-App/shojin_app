import 'package:flutter/material.dart';
import 'package:flutter_math_fork/flutter_math.dart';
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
      statement:
          '**重要**な条件です。\n'
          '- 整数 A と整数 B が与えられます。\n'
          '[[[DETAILS:補足説明]]]\n補足の本文です。\n[[[/DETAILS]]]',
      constraints: '1 <= A, B <= 1000000000',
      inputFormat: '入力は以下の形式で標準入力から与えられる。\n\n```\n\$A\$ \$B\$\n```',
      outputFormat: '答えを出力してください。',
      samples: [
        SampleIO(input: '1 2', output: '3', index: 1),
        SampleIO(input: '10 20', output: '30', index: 2),
      ],
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
    expect(find.text('入力例 2'), findsOneWidget);
    expect(find.text('出力例 2'), findsOneWidget);
    expect(find.byTooltip('入力例 1をコピー'), findsOneWidget);
    final formattedStatement = tester.widget<RichText>(
      find.byWidgetPredicate(
        (widget) =>
            widget is RichText && widget.text.toPlainText().contains('重要な条件'),
      ),
    );
    expect(formattedStatement.text.toPlainText(), contains('• 整数 A'));
    expect(
      _findTextSpan(formattedStatement.text, '重要')?.style?.fontWeight,
      FontWeight.w700,
    );
    // 入力の説明は形式のコード背景とは別のTexWidgetとして描画される。
    expect(find.byKey(const Key('problem-input-description')), findsOneWidget);
    expect(find.byKey(const Key('problem-input-format')), findsOneWidget);
    expect(
      find.descendant(
        of: find.byKey(const Key('problem-input-format')),
        matching: find.byType(Math),
      ),
      findsNWidgets(2),
    );
    expect(find.byKey(const ValueKey('problem-details-補足説明')), findsOneWidget);
    expect(
      find.byKey(const ValueKey('problem-details-content-補足説明')),
      findsNothing,
    );
    await tester.tap(find.text('補足説明'));
    await tester.pumpAndSettle();
    expect(
      find.byKey(const ValueKey('problem-details-content-補足説明')),
      findsOneWidget,
    );

    final appBarBottom = tester.getBottomLeft(find.text('問題詳細')).dy;
    final problemCard = find.byKey(const Key('problem-content-card'));
    expect(tester.getTopLeft(problemCard).dy - appBarBottom, lessThan(12));

    final inputBlock = tester.getRect(
      find.byKey(const ValueKey('sample-block-入力例 1')),
    );
    final outputBlock = tester.getRect(
      find.byKey(const ValueKey('sample-block-出力例 1')),
    );
    expect(outputBlock.top - inputBlock.bottom, 12);
    final secondInputBlock = tester.getRect(
      find.byKey(const ValueKey('sample-block-入力例 2')),
    );
    expect(secondInputBlock.top - outputBlock.bottom, 20);
    final sampleText = tester.widget<SelectableText>(
      find.descendant(
        of: find.byKey(const ValueKey('sample-block-入力例 1')),
        matching: find.byType(SelectableText),
      ),
    );
    expect(sampleText.style?.fontFamily, defaultCodeFontFamily);
    expect(
      tester.getSize(find.byKey(const ValueKey('sample-header-入力例 1'))).height,
      40,
    );

    final problemScrollView = find.byType(SingleChildScrollView).first;
    expect(tester.getBottomLeft(problemScrollView).dy, 800);
    await tester.scrollUntilVisible(
      find.text('出典: AtCoder'),
      300,
      scrollable: find
          .descendant(of: problemScrollView, matching: find.byType(Scrollable))
          .first,
    );
    expect(
      tester.getBottomLeft(find.text('出典: AtCoder')).dy,
      lessThanOrEqualTo(720),
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('multiple input code fences keep identification keys unique', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final problem = Problem(
      title: 'A - 複数形式の入力',
      contestId: 'abc999',
      contestName: 'AtCoder Beginner Contest 999',
      statement: '問題文です。',
      constraints: '制約です。',
      inputFormat:
          '最初の入力です。\n```\n\$N\$\n```\n'
          '続いて次の入力です。\n```\n\$A_1\$ ... \$A_N\$\n```',
      outputFormat: '答えを出力してください。',
      samples: const [],
      url: 'https://atcoder.jp/contests/abc999/tasks/abc999_a',
    );

    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => ThemeProvider(),
        child: MaterialApp(
          home: ProblemDetailScreen(
            problemIdToLoad: 'abc999_a',
            atCoderService: _FakeAtCoderService(problem),
            onProblemChanged: (_) {},
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('problem-input-description')), findsOneWidget);
    expect(find.byKey(const Key('problem-input-format')), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}

TextSpan? _findTextSpan(InlineSpan span, String text) {
  if (span is! TextSpan) return null;
  if (span.text == text) return span;
  for (final child in span.children ?? const <InlineSpan>[]) {
    final match = _findTextSpan(child, text);
    if (match != null) return match;
  }
  return null;
}

class _FakeAtCoderService extends AtCoderService {
  _FakeAtCoderService(this.problem);

  final Problem problem;

  @override
  bool isValidAtCoderUrl(String url) => true;

  @override
  Future<Problem> fetchProblem(String url) async => problem;
}
