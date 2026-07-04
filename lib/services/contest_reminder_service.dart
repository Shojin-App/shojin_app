import 'dart:developer' as developer;

import '../models/contest.dart';
import '../models/reminder_setting.dart';
import 'contest_service.dart';
import 'notification_service.dart';
import 'reminder_storage_service.dart';

class ContestReminderService {
  ContestReminderService({
    ContestService? contestService,
    ReminderStorageService? storageService,
    NotificationService? notificationService,
  }) : _contestService = contestService ?? ContestService(),
       _storageService = storageService ?? ReminderStorageService(),
       _notificationService = notificationService ?? NotificationService();

  static const int _notificationIdBase = 100000;
  static const int _notificationIdLimit = 900000000;

  final ContestService _contestService;
  final ReminderStorageService _storageService;
  final NotificationService _notificationService;

  Future<void> synchronize() async {
    try {
      await _cancelExistingContestReminders();

      final storedSettings = await _storageService.loadReminderSettings();
      // 未設定の新規ユーザーには通知を自動登録しない。権限要求と有効化は
      // リマインダー設定画面での明示操作に限定する。
      if (storedSettings.isEmpty) return;
      final settings = storedSettings;
      final enabledSettings = {
        for (final setting in settings)
          if (setting.isEnabled) setting.contestType: setting,
      };
      if (enabledSettings.isEmpty) return;

      final contests = await _contestService.getUpcomingContests();
      final now = DateTime.now();

      for (final contest in contests) {
        final setting = enabledSettings[_contestTypeOf(contest)];
        if (setting == null) continue;

        for (final minutes in setting.minutesBefore.toSet()) {
          final scheduledTime = contest.startTime.toLocal().subtract(
            Duration(minutes: minutes),
          );
          if (!scheduledTime.isAfter(now)) continue;

          await _notificationService.scheduleNotification(
            id: _notificationId(contest.url, minutes),
            title: '${_shortContestName(contest)} がまもなく始まります',
            body: minutes == 0
                ? '${contest.nameJa} の開始時刻です'
                : '${contest.nameJa} の開始$minutes分前です',
            scheduledTime: scheduledTime,
            payload: contest.url,
          );
        }
      }
    } catch (error, stackTrace) {
      developer.log(
        'Failed to synchronize contest reminders',
        name: 'ContestReminderService',
        error: error,
        stackTrace: stackTrace,
      );
    }
  }

  Future<void> _cancelExistingContestReminders() async {
    final pending = await _notificationService.pendingRequests();
    for (final request in pending) {
      if (request.id >= _notificationIdBase &&
          request.id < _notificationIdLimit) {
        await _notificationService.cancelNotification(request.id);
      }
    }
  }

  ContestType _contestTypeOf(Contest contest) {
    final name = '${contest.nameJa} ${contest.nameEn}';
    if (name.contains('Beginner Contest')) return ContestType.abc;
    if (name.contains('Regular Contest')) return ContestType.arc;
    if (name.contains('Grand Contest')) return ContestType.agc;
    if (name.contains('Heuristic Contest')) return ContestType.ahc;
    return ContestType.other;
  }

  String _shortContestName(Contest contest) {
    final match = RegExp(
      r'AtCoder (?:Beginner|Regular|Grand|Heuristic) Contest \d+',
    ).firstMatch('${contest.nameJa} ${contest.nameEn}');
    return match?.group(0) ?? contest.nameJa;
  }

  int _notificationId(String contestUrl, int minutes) {
    var hash = 2166136261;
    for (final codeUnit in '$contestUrl:$minutes'.codeUnits) {
      hash ^= codeUnit;
      hash = (hash * 16777619) & 0x7fffffff;
    }
    return _notificationIdBase +
        (hash % (_notificationIdLimit - _notificationIdBase));
  }
}
