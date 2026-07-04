import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  static const androidSmallIcon = 'ic_launcher_monochrome';
  static const reminderChannelId = 'shojin_app_channel_id';
  static const reminderChannelName = 'コンテスト通知';
  static const reminderChannelDescription = 'AtCoderコンテスト開始前のリマインダー';

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  bool _isInitialized = false;

  Future<void> initialize() async {
    if (_isInitialized) return;

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings(
          // Android通知バーは単色マスクを前提とするため、
          // フルカラーのランチャーアイコンとは分ける。
          androidSmallIcon,
        );

    // iOS の初期化設定 (macOS も同様)
    const DarwinInitializationSettings
    initializationSettingsIOS = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
      // onDidReceiveLocalNotification: onDidReceiveLocalNotification, // 古いiOSバージョン用
    );

    const InitializationSettings
    initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
      macOS:
          initializationSettingsIOS, // macOS も DarwinInitializationSettings を使用
    );

    await flutterLocalNotificationsPlugin.initialize(
      settings: initializationSettings,
      // onDidReceiveNotificationResponse: onDidReceiveNotificationResponse, // 通知タップ時の処理
    );
    _isInitialized = true;

    // タイムゾーンの初期化
    tz_data.initializeTimeZones(); // tz.initializeTimeZones(); から変更
    // tz.setLocalLocation(tz.getLocation('Asia/Tokyo')); // 必要に応じてデフォルトのタイムゾーンを設定
  }

  // 通知タップ時のコールバック (例)
  // void onDidReceiveNotificationResponse(NotificationResponse notificationResponse) async {
  //   final String? payload = notificationResponse.payload;
  //   if (notificationResponse.payload != null) {
  //     debugPrint('notification payload: $payload');
  //   }
  //   // ペイロードに基づいて特定の画面に遷移するなどの処理
  // }

  // 古いiOSバージョン用の通知受信コールバック (例)
  // void onDidReceiveLocalNotification(
  //     int id, String? title, String? body, String? payload) async {
  //   // display a dialog with the notification details, tap ok to go to another page
  // }

  Future<bool> requestPermissions() async {
    await initialize();
    final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
        flutterLocalNotificationsPlugin
            .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin
            >();
    final granted = await androidImplementation
        ?.requestNotificationsPermission();
    // Android 12以前では実行時権限がなくnullになる場合がある。
    return granted ?? true;
  }

  Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledTime,
    String? payload,
  }) async {
    await initialize();
    await flutterLocalNotificationsPlugin.zonedSchedule(
      id: id,
      title: title,
      body: body,
      scheduledDate: tz.TZDateTime.from(scheduledTime.toUtc(), tz.UTC),
      notificationDetails: NotificationDetails(
        android: AndroidNotificationDetails(
          reminderChannelId,
          reminderChannelName,
          channelDescription: reminderChannelDescription,
          importance: Importance.max,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
        macOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      payload: payload,
    );
  }

  Future<List<PendingNotificationRequest>> pendingRequests() {
    return flutterLocalNotificationsPlugin.pendingNotificationRequests();
  }

  Future<void> cancelNotification(int id) async {
    await flutterLocalNotificationsPlugin.cancel(id: id);
  }

  Future<void> cancelAllNotifications() async {
    await flutterLocalNotificationsPlugin.cancelAll();
  }
}
