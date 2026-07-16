import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shojin_app/models/contest.dart';
import 'package:shojin_app/models/reminder_setting.dart';
import 'package:shojin_app/services/contest_reminder_service.dart';
import 'package:shojin_app/services/contest_service.dart';
import 'package:shojin_app/services/notification_service.dart';
import 'package:shojin_app/services/reminder_storage_service.dart';

class _FakeContestService extends ContestService {
  _FakeContestService(this.contests, {this.error});

  final List<Contest> contests;
  final Object? error;
  int requestCount = 0;

  @override
  Future<List<Contest>> getUpcomingContests() async {
    requestCount += 1;
    if (error != null) throw error!;
    return contests;
  }
}

class _FakeReminderStorageService extends ReminderStorageService {
  _FakeReminderStorageService(this.settings);

  final List<ReminderSetting> settings;

  @override
  Future<List<ReminderSetting>> loadReminderSettings() async => settings;
}

class _ScheduledNotification {
  const _ScheduledNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.scheduledTime,
    required this.payload,
  });

  final int id;
  final String title;
  final String body;
  final DateTime scheduledTime;
  final String? payload;
}

class _FakeNotificationService extends NotificationService {
  _FakeNotificationService({List<PendingNotificationRequest>? pending})
    : pending = pending ?? [];

  final List<PendingNotificationRequest> pending;
  final List<int> cancelledIds = [];
  final List<_ScheduledNotification> scheduled = [];

  @override
  Future<List<PendingNotificationRequest>> pendingRequests() async =>
      List.of(pending);

  @override
  Future<void> cancelNotification(int id) async {
    cancelledIds.add(id);
    pending.removeWhere((request) => request.id == id);
  }

  @override
  Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledTime,
    String? payload,
  }) async {
    scheduled.add(
      _ScheduledNotification(
        id: id,
        title: title,
        body: body,
        scheduledTime: scheduledTime,
        payload: payload,
      ),
    );
  }
}

Contest _contest({
  required String name,
  required String url,
  required DateTime startTime,
}) {
  return Contest(
    nameJa: name,
    nameEn: name,
    url: url,
    startTime: startTime,
    durationMin: 100,
    status: 'Upcoming',
  );
}

void main() {
  const managedNotificationId = 100123;
  const unrelatedNotificationId = 42;

  test(
    'disabling every reminder cancels only contest reminder alarms',
    () async {
      final contestService = _FakeContestService([]);
      final notificationService = _FakeNotificationService(
        pending: const [
          PendingNotificationRequest(
            managedNotificationId,
            'contest',
            null,
            null,
          ),
          PendingNotificationRequest(
            unrelatedNotificationId,
            'other',
            null,
            null,
          ),
        ].toList(),
      );
      final service = ContestReminderService(
        contestService: contestService,
        storageService: _FakeReminderStorageService([
          ReminderSetting(
            contestType: ContestType.abc,
            minutesBefore: [15],
            isEnabled: false,
          ),
        ]),
        notificationService: notificationService,
      );

      await service.synchronize();

      expect(contestService.requestCount, 0);
      expect(notificationService.cancelledIds, [managedNotificationId]);
      expect(notificationService.pending.map((request) => request.id), [
        unrelatedNotificationId,
      ]);
      expect(notificationService.scheduled, isEmpty);
    },
  );

  test('missing settings also clear stale contest reminder alarms', () async {
    final notificationService = _FakeNotificationService(
      pending: const [
        PendingNotificationRequest(
          managedNotificationId,
          'contest',
          null,
          null,
        ),
      ].toList(),
    );
    final service = ContestReminderService(
      contestService: _FakeContestService([]),
      storageService: _FakeReminderStorageService([]),
      notificationService: notificationService,
    );

    await service.synchronize();

    expect(notificationService.cancelledIds, [managedNotificationId]);
  });

  test(
    'schedules only enabled contest types and future reminder times',
    () async {
      final now = DateTime.now();
      final abc = _contest(
        name: 'AtCoder Beginner Contest 500',
        url: 'https://atcoder.jp/contests/abc500',
        startTime: now.add(const Duration(hours: 2)),
      );
      final arc = _contest(
        name: 'AtCoder Regular Contest 300',
        url: 'https://atcoder.jp/contests/arc300',
        startTime: now.add(const Duration(hours: 3)),
      );
      final notificationService = _FakeNotificationService(
        pending: const [
          PendingNotificationRequest(
            managedNotificationId,
            'old contest',
            null,
            null,
          ),
        ].toList(),
      );
      final service = ContestReminderService(
        contestService: _FakeContestService([abc, arc]),
        storageService: _FakeReminderStorageService([
          ReminderSetting(
            contestType: ContestType.abc,
            // 180分前は既に過ぎているため予約対象外。
            minutesBefore: [15, 15, 180],
          ),
          ReminderSetting(
            contestType: ContestType.arc,
            minutesBefore: [15],
            isEnabled: false,
          ),
        ]),
        notificationService: notificationService,
      );

      await service.synchronize();

      expect(notificationService.cancelledIds, [managedNotificationId]);
      expect(notificationService.scheduled, hasLength(1));
      final scheduled = notificationService.scheduled.single;
      expect(scheduled.id, inInclusiveRange(100000, 899999999));
      expect(scheduled.title, 'AtCoder Beginner Contest 500 がまもなく始まります');
      expect(scheduled.body, 'AtCoder Beginner Contest 500 の開始15分前です');
      expect(
        scheduled.scheduledTime,
        abc.startTime.subtract(const Duration(minutes: 15)),
      );
      expect(scheduled.payload, abc.url);
    },
  );

  test('keeps existing alarms when refreshing contests fails', () async {
    final notificationService = _FakeNotificationService(
      pending: const [
        PendingNotificationRequest(
          managedNotificationId,
          'existing contest',
          null,
          null,
        ),
      ].toList(),
    );
    final service = ContestReminderService(
      contestService: _FakeContestService([], error: Exception('offline')),
      storageService: _FakeReminderStorageService([
        ReminderSetting(contestType: ContestType.abc, minutesBefore: [15]),
      ]),
      notificationService: notificationService,
    );

    await service.synchronize();

    expect(notificationService.cancelledIds, isEmpty);
    expect(notificationService.pending, hasLength(1));
    expect(notificationService.scheduled, isEmpty);
  });
}
