import 'package:flutter_test/flutter_test.dart';
import 'package:shojin_app/services/notification_service.dart';

void main() {
  test('Android reminder channel uses user-facing Japanese labels', () {
    expect(NotificationService.androidSmallIcon, 'ic_launcher_monochrome');
    expect(NotificationService.reminderChannelId, 'shojin_app_channel_id');
    expect(NotificationService.reminderChannelName, 'コンテスト通知');
    expect(
      NotificationService.reminderChannelDescription,
      'AtCoderコンテスト開始前のリマインダー',
    );
  });
}
