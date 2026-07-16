import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:m3e_collection/m3e_collection.dart';
import 'package:shojin_app/widgets/shared/app_bottom_navigation.dart';

void main() {
  testWidgets('shows every label at a regular width', (tester) async {
    tester.view.physicalSize = const Size(390, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          bottomNavigationBar: AppBottomNavigation(
            selectedIndex: 0,
            onDestinationSelected: (_) {},
          ),
        ),
      ),
    );

    final navigation = tester.widget<NavigationBarM3E>(
      find.byType(NavigationBarM3E),
    );
    expect(navigation.labelBehavior, NavBarM3ELabelBehavior.alwaysShow);
    expect(tester.takeException(), isNull);
  });

  testWidgets('shows only the selected label with enlarged text', (
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
        home: Scaffold(
          bottomNavigationBar: AppBottomNavigation(
            selectedIndex: 3,
            onDestinationSelected: (_) {},
          ),
        ),
      ),
    );

    final navigation = tester.widget<NavigationBarM3E>(
      find.byType(NavigationBarM3E),
    );
    expect(navigation.labelBehavior, NavBarM3ELabelBehavior.onlySelected);
    expect(tester.takeException(), isNull);
  });

  testWidgets('hides while the Android software keyboard is open', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(
        home: MediaQuery(
          data: const MediaQueryData(
            size: Size(360, 800),
            viewInsets: EdgeInsets.only(bottom: 300),
          ),
          child: Scaffold(
            bottomNavigationBar: AppBottomNavigation(
              selectedIndex: 3,
              onDestinationSelected: (_) {},
            ),
          ),
        ),
      ),
    );

    expect(find.byType(NavigationBarM3E), findsNothing);
    expect(tester.getSize(find.byType(AppBottomNavigation)).height, 0);
    expect(tester.takeException(), isNull);
  });
}
