import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // TextInputFormatterのため
import 'package:m3e_collection/m3e_collection.dart';
import '../models/reminder_setting.dart';
import '../services/reminder_storage_service.dart';
import '../services/contest_reminder_service.dart';
import '../utils/responsive_layout.dart';
import '../widgets/shared/app_loading_indicator.dart';

class ReminderSettingsScreen extends StatefulWidget {
  const ReminderSettingsScreen({super.key});

  @override
  State<ReminderSettingsScreen> createState() => _ReminderSettingsScreenState();
}

class _NotificationTimeOption {
  final String label;
  final int? value; // null の場合はカスタム入力を示す

  const _NotificationTimeOption(this.label, this.value);
}

class _ReminderSettingsScreenState extends State<ReminderSettingsScreen> {
  final ReminderStorageService _storageService = ReminderStorageService();
  List<ReminderSetting> _reminderSettings = [];
  bool _isLoading = true;

  final Map<ContestType, String> _contestTypeNames = {
    ContestType.abc: 'AtCoder Beginner Contest',
    ContestType.arc: 'AtCoder Regular Contest',
    ContestType.agc: 'AtCoder Grand Contest',
    ContestType.ahc: 'AtCoder Heuristic Contest',
  };

  final Map<ContestType, String> _contestTypeLabels = {
    ContestType.abc: 'ABC',
    ContestType.arc: 'ARC',
    ContestType.agc: 'AGC',
    ContestType.ahc: 'AHC',
  };

  static const List<_NotificationTimeOption> _timeOptions = [
    _NotificationTimeOption('0分前', 0),
    _NotificationTimeOption('5分前', 5),
    _NotificationTimeOption('10分前', 10),
    _NotificationTimeOption('15分前', 15),
    _NotificationTimeOption('30分前', 30),
    _NotificationTimeOption('1時間前', 60),
    _NotificationTimeOption('2時間前', 120),
    _NotificationTimeOption('カスタム...', null), // カスタム入力用
  ];

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    setState(() {
      _isLoading = true;
    });
    final loadedSettings = await _storageService.loadReminderSettings();
    for (final setting in loadedSettings) {
      setting.minutesBefore = setting.minutesBefore.toSet().toList()..sort();
    }
    for (var type in _contestTypeNames.keys) {
      if (!loadedSettings.any((s) => s.contestType == type)) {
        loadedSettings.add(
          ReminderSetting(
            contestType: type,
            minutesBefore: [15],
            isEnabled: true,
          ),
        );
      }
    }
    loadedSettings.sort(
      (a, b) =>
          _contestTypeNames.keys.toList().indexOf(a.contestType) -
          _contestTypeNames.keys.toList().indexOf(b.contestType),
    );

    setState(() {
      _reminderSettings = loadedSettings;
      _isLoading = false;
    });
  }

  Future<void> _saveSettings() async {
    for (var setting in _reminderSettings) {
      if (setting.minutesBefore.isEmpty) {
        setting.minutesBefore = [15];
      }
    }
    await _storageService.saveReminderSettings(_reminderSettings);
    await ContestReminderService().synchronize();
  }

  Future<void> _showCustomTimeInputDialog(int settingIndex) async {
    final TextEditingController controller = TextEditingController();
    final newTime = await showDialog<int>(
      context: context,
      builder: (context) {
        final theme = Theme.of(context);
        final colorScheme = theme.colorScheme;

        return AlertDialog(
          title: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.timer_outlined,
                  color: colorScheme.onPrimaryContainer,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  '通知時間を入力',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest.withValues(
                    alpha: 0.45,
                  ),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: colorScheme.outlineVariant.withValues(alpha: 0.7),
                  ),
                ),
                child: Text(
                  'コンテスト開始の何分前に通知するかを入力してください。0分前も指定できます。',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    height: 1.4,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: controller,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: InputDecoration(
                  labelText: '分前',
                  hintText: '例: 10',
                  prefixIcon: const Icon(Icons.schedule),
                  filled: true,
                  fillColor: colorScheme.surfaceContainerHighest.withValues(
                    alpha: 0.35,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: colorScheme.outlineVariant),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: colorScheme.outlineVariant),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: colorScheme.primary,
                      width: 1.6,
                    ),
                  ),
                ),
              ),
            ],
          ),
          actions: [
            ButtonM3E(
              style: ButtonM3EStyle.text,
              onPressed: () => Navigator.of(context).pop(),
              icon: const Icon(Icons.close),
              label: const Text('キャンセル'),
            ),
            ButtonM3E(
              style: ButtonM3EStyle.text,
              onPressed: () {
                final value = int.tryParse(controller.text);
                if (value != null && value >= 0) {
                  // 0分前も許可
                  Navigator.of(context).pop(value);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('有効な数値を入力してください')),
                  );
                }
              },
              icon: const Icon(Icons.check),
              label: const Text('決定'),
            ),
          ],
        );
      },
    );

    if (newTime != null) {
      setState(() {
        if (!_reminderSettings[settingIndex].minutesBefore.contains(newTime)) {
          _reminderSettings[settingIndex].minutesBefore.add(newTime);
          _reminderSettings[settingIndex].minutesBefore.sort();
        }
      });
      await _saveSettings();
    }
  }

  Future<void> _addNotificationTime(int settingIndex) async {
    final selectedTimes = _reminderSettings[settingIndex].minutesBefore.toSet();
    final selectedOption = await showDialog<_NotificationTimeOption>(
      context: context,
      builder: (BuildContext context) {
        final theme = Theme.of(context);
        final colorScheme = theme.colorScheme;

        return AlertDialog(
          scrollable: true,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Row(
            children: [
              Icon(Icons.add_alarm_outlined, color: colorScheme.primary),
              const SizedBox(width: 12),
              const Expanded(child: Text('通知時間を選択')),
            ],
          ),
          content: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 320),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: _timeOptions.map((option) {
                final isSelected =
                    option.value != null &&
                    selectedTimes.contains(option.value);
                return Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Material(
                    color: isSelected
                        ? colorScheme.primaryContainer.withValues(alpha: 0.6)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                    child: ListTile(
                      dense: true,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      leading: Icon(
                        option.value == null
                            ? Icons.tune
                            : Icons.schedule_outlined,
                      ),
                      title: Text(option.label),
                      trailing: isSelected
                          ? Icon(Icons.check, color: colorScheme.primary)
                          : const Icon(Icons.chevron_right),
                      enabled: !isSelected,
                      onTap: isSelected
                          ? null
                          : () => Navigator.pop(context, option),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          actions: [
            TextButton.icon(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.close),
              label: const Text('キャンセル'),
            ),
          ],
        );
      },
    );

    if (selectedOption != null) {
      if (selectedOption.value != null) {
        // 事前定義された時間
        setState(() {
          if (!_reminderSettings[settingIndex].minutesBefore.contains(
            selectedOption.value!,
          )) {
            _reminderSettings[settingIndex].minutesBefore.add(
              selectedOption.value!,
            );
            _reminderSettings[settingIndex].minutesBefore.sort();
          }
        });
        await _saveSettings();
      } else {
        // カスタム入力
        await _showCustomTimeInputDialog(settingIndex);
      }
    }
  }

  void _removeNotificationTime(int settingIndex, int timeToRemove) {
    setState(() {
      _reminderSettings[settingIndex].minutesBefore.remove(timeToRemove);
    });
    _saveSettings();
  }

  Widget _buildStateCard({
    required IconData icon,
    required String title,
    required String message,
    Widget? child,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          clipBehavior: Clip.antiAlias,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(icon, color: colorScheme.onPrimaryContainer),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            message,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                if (child != null) child,
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildReminderCard(int index) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final setting = _reminderSettings[index];
    final contestName = _contestTypeNames[setting.contestType] ?? 'その他';
    final label = _contestTypeLabels[setting.contestType] ?? 'OTHER';
    final labelColor = setting.isEnabled
        ? colorScheme.primaryContainer
        : colorScheme.surfaceContainerHighest;
    final onLabelColor = setting.isEnabled
        ? colorScheme.onPrimaryContainer
        : colorScheme.onSurfaceVariant;

    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: labelColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(
                      label,
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: onLabelColor,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        contestName,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        setting.isEnabled ? '通知はONです' : '通知はOFFです',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: setting.isEnabled
                              ? colorScheme.primary
                              : colorScheme.onSurfaceVariant,
                          fontWeight: setting.isEnabled
                              ? FontWeight.w700
                              : FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),
                Switch(
                  value: setting.isEnabled,
                  onChanged: (bool value) {
                    setState(() {
                      setting.isEnabled = value;
                    });
                    _saveSettings();
                  },
                ),
              ],
            ),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest.withValues(
                  alpha: 0.45,
                ),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: colorScheme.outlineVariant.withValues(alpha: 0.7),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.notifications_active_outlined,
                        size: 18,
                        color: colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '通知タイミング',
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8.0,
                    runSpacing: 8.0,
                    children: [
                      ...setting.minutesBefore.map((time) {
                        return InputChip(
                          label: Text('$time分前'),
                          onDeleted: () => _removeNotificationTime(index, time),
                        );
                      }),
                      ActionChip(
                        avatar: const Icon(Icons.add_alarm_outlined, size: 18),
                        label: const Text('追加'),
                        onPressed: () => _addNotificationTime(index),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarM3E(title: const Text('リマインダー設定')),
      body: _isLoading
          ? _buildStateCard(
              icon: Icons.notifications_active_outlined,
              title: 'リマインダー設定を読み込み中',
              message: '保存済みの通知タイミングを確認しています。',
              child: const Padding(
                padding: EdgeInsets.only(top: 16),
                child: AppLoadingIndicator(semanticsLabel: 'リマインダー設定を読み込み中'),
              ),
            )
          : _reminderSettings.isEmpty
          ? _buildStateCard(
              icon: Icons.notifications_off_outlined,
              title: '設定項目がありません',
              message: 'コンテスト種別のリマインダー設定を読み込めませんでした。',
            )
          : ListView.builder(
              padding: ResponsiveLayout.listPadding(context),
              itemCount: _reminderSettings.length,
              itemBuilder: (context, index) => _buildReminderCard(index),
            ),
    );
  }
}
