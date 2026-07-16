import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shojin_app/screens/reminder_settings_screen.dart';
import 'package:shojin_app/services/contest_reminder_service.dart';
import 'package:shojin_app/services/notification_service.dart';

class _FakeNotificationService extends NotificationService {
  bool granted = false;
  int requestCount = 0;

  @override
  Future<bool> requestPermissions() async {
    requestCount += 1;
    return granted;
  }
}

class _FakeContestReminderService extends ContestReminderService {
  int synchronizeCount = 0;

  @override
  Future<void> synchronize() async {
    synchronizeCount += 1;
  }
}

void main() {
  testWidgets('reminder settings support enlarged text on a narrow screen', (
    tester,
  ) async {
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
        home: const ReminderSettingsScreen(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('リマインダー設定'), findsOneWidget);
    expect(find.byType(Switch), findsWidgets);
    expect(find.text('ABC'), findsOneWidget);
    expect(find.text('ARC'), findsOneWidget);
    expect(tester.takeException(), isNull);

    await tester.tap(find.byTooltip('通知時間を追加').first);
    await tester.pumpAndSettle();

    expect(find.text('通知時間を選択'), findsOneWidget);
    final dialog = tester.widget<AlertDialog>(find.byType(AlertDialog));
    final dialogShape = dialog.shape! as RoundedRectangleBorder;
    expect(dialogShape.borderRadius, BorderRadius.circular(8));
    expect(tester.takeException(), isNull);
  });

  testWidgets('requests Android notification permission when enabling', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final notificationService = _FakeNotificationService();
    final reminderService = _FakeContestReminderService();

    await tester.pumpWidget(
      MaterialApp(
        home: ReminderSettingsScreen(
          notificationService: notificationService,
          reminderService: reminderService,
        ),
      ),
    );
    await tester.pumpAndSettle();

    final firstSwitch = find.byType(Switch).first;
    expect(tester.widget<Switch>(firstSwitch).value, isFalse);

    await tester.tap(firstSwitch);
    await tester.pumpAndSettle();

    expect(notificationService.requestCount, 1);
    expect(tester.widget<Switch>(firstSwitch).value, isFalse);
    expect(find.text('通知が許可されなかったため、リマインダーは有効にできませんでした'), findsOneWidget);
    expect(reminderService.synchronizeCount, 0);

    notificationService.granted = true;
    await tester.tap(firstSwitch);
    await tester.pumpAndSettle();

    expect(notificationService.requestCount, 2);
    expect(tester.widget<Switch>(firstSwitch).value, isTrue);
    expect(reminderService.synchronizeCount, 1);
    expect(tester.takeException(), isNull);
  });
}
