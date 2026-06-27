import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shojin_app/main.dart';

void main() {
  testWidgets('switches immediately when animations are disabled', (
    tester,
  ) async {
    var selectedIndex = 0;
    late StateSetter update;

    await tester.pumpWidget(
      MaterialApp(
        home: MediaQuery(
          data: const MediaQueryData(disableAnimations: true),
          child: StatefulBuilder(
            builder: (context, setState) {
              update = setState;
              return AnimatedTabStack(
                index: selectedIndex,
                children: const [Text('ホーム'), Text('設定')],
              );
            },
          ),
        ),
      ),
    );

    expect(find.text('ホーム'), findsOneWidget);
    expect(find.text('設定'), findsNothing);

    update(() => selectedIndex = 1);
    await tester.pump();

    expect(find.text('ホーム'), findsNothing);
    expect(find.text('設定'), findsOneWidget);
  });
}
