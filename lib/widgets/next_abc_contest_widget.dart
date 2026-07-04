import 'package:flutter/material.dart';
import 'package:m3e_collection/m3e_collection.dart';
import 'package:provider/provider.dart';

import '../models/contest.dart';
import '../models/reminder_setting.dart';
import '../providers/contest_provider.dart';
import '../screens/reminder_settings_screen.dart';
import '../screens/upcoming_contests_screen.dart';
import '../services/reminder_storage_service.dart';
import 'shared/app_loading_indicator.dart';
import 'shared/app_state_card.dart';
import 'shared/responsive_action.dart';

class NextABCContestWidget extends StatefulWidget {
  const NextABCContestWidget({super.key});

  @override
  State<NextABCContestWidget> createState() => _NextABCContestWidgetState();
}

class _NextABCContestWidgetState extends State<NextABCContestWidget> {
  ReminderSetting? _abcReminderSetting;
  final _reminderStorage = ReminderStorageService();

  @override
  void initState() {
    super.initState();
    _loadReminderSetting();
    // 初期化時に次回のABCを取得
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ContestProvider>().fetchNextABC();
    });
  }

  Future<void> _loadReminderSetting() async {
    final setting = await _reminderStorage.getReminderSetting(ContestType.abc);
    if (mounted) {
      setState(() {
        _abcReminderSetting = setting;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ContestProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return _buildStateCard(
            context,
            icon: Icons.event_available,
            title: '次回のABC',
            message: 'コンテスト情報を取得しています',
            child: const Padding(
              padding: EdgeInsets.only(top: 16),
              child: Center(
                child: AppLoadingIndicator(semanticsLabel: 'コンテスト情報を読み込み中'),
              ),
            ),
          );
        }

        if (provider.error != null) {
          return _buildStateCard(
            context,
            icon: Icons.error_outline,
            title: 'コンテスト情報の取得に失敗しました',
            message: '通信状況を確認して再試行してください。',
            isError: true,
            child: Padding(
              padding: const EdgeInsets.only(top: 16),
              child: ResponsiveAction(
                child: ButtonM3E(
                  onPressed: () => provider.fetchNextABC(),
                  label: const Text('再試行'),
                  style: ButtonM3EStyle.filled,
                ),
              ),
            ),
          );
        }

        final nextABC = provider.nextABC;
        if (nextABC == null) {
          return _buildStateCard(
            context,
            icon: Icons.event_busy,
            title: '次回のABCが見つかりません',
            message: 'AtCoderの予定が公開されたあとに再度確認できます。',
          );
        }

        return _buildContestCard(context, nextABC);
      },
    );
  }

  Widget _buildStateCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String message,
    bool isError = false,
    Widget? child,
  }) {
    return AppStateCard(
      icon: icon,
      title: title,
      message: message,
      isError: isError,
      child: child,
    );
  }

  Widget _buildContestCard(BuildContext context, Contest contest) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final borderRadius = BorderRadius.circular(8);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: borderRadius),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const UpcomingContestsScreen(),
            ),
          );
        },
        borderRadius: borderRadius,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.event_available,
                      color: colorScheme.onPrimaryContainer,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '次回のABC',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          contest.startTimeWithWeekday,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  _buildContestTypeChip(context, contest),
                  const SizedBox(width: 8),
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                    color: colorScheme.outline,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                contest.nameJa,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              if (contest.nameEn.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  contest.nameEn,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest.withValues(
                    alpha: 0.45,
                  ),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: colorScheme.outlineVariant.withValues(alpha: 0.7),
                  ),
                ),
                child: Column(
                  children: [
                    _buildInfoRow(
                      context,
                      Icons.timer_outlined,
                      '時間',
                      contest.durationString,
                    ),
                    if (contest.ratedRange != null) ...[
                      const SizedBox(height: 8),
                      _buildInfoRow(
                        context,
                        Icons.bar_chart,
                        'レート対象',
                        contest.ratedRange!,
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 14),
              const Divider(),
              const SizedBox(height: 8),
              _buildReminderRow(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildReminderRow(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final isEnabled = _abcReminderSetting?.isEnabled ?? true;
    final minutes = _abcReminderSetting?.minutesBefore ?? [15];

    String reminderText;
    IconData reminderIcon;
    Color reminderColor;

    if (!isEnabled) {
      reminderText = 'リマインダー: 無効';
      reminderIcon = Icons.notifications_off_outlined;
      reminderColor = colorScheme.onSurfaceVariant;
    } else {
      if (minutes.isEmpty) {
        reminderText = 'リマインダー: 有効 (時刻未設定)';
      } else {
        reminderText = 'リマインダー: ${minutes.map((m) => '$m分前').join(', ')}';
      }
      reminderIcon = Icons.notifications_active;
      reminderColor = colorScheme.primary;
    }

    return Row(
      children: [
        Icon(reminderIcon, size: 20, color: reminderColor),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            reminderText,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: reminderColor,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        IconButtonM3E(
          icon: Icon(Icons.settings, color: colorScheme.onSurfaceVariant),
          tooltip: 'リマインダー設定',
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const ReminderSettingsScreen(),
              ),
            ).then((_) => _loadReminderSetting());
          },
        ),
      ],
    );
  }

  Widget _buildInfoRow(
    BuildContext context,
    IconData icon,
    String label,
    String value,
  ) {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      children: [
        Icon(icon, size: 16, color: colorScheme.onSurfaceVariant),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant),
        ),
        Expanded(
          child: Text(
            value,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w500),
          ),
        ),
      ],
    );
  }

  Widget _buildContestTypeChip(BuildContext context, Contest contest) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    String type = 'その他';
    Color containerColor = colorScheme.surfaceContainerHighest;
    Color foregroundColor = colorScheme.onSurfaceVariant;

    final nameJa = contest.nameJa;
    final nameEn = contest.nameEn;

    if (contest.isABC ||
        nameJa.contains('Beginner Contest') ||
        nameEn.contains('Beginner Contest') ||
        nameJa.contains('AtCoder Beginner Contest') ||
        nameEn.contains('AtCoder Beginner Contest')) {
      type = 'ABC';
      containerColor = colorScheme.primaryContainer;
      foregroundColor = colorScheme.onPrimaryContainer;
    } else if (nameJa.contains('Regular Contest') ||
        nameEn.contains('Regular Contest') ||
        nameJa.contains('AtCoder Regular Contest') ||
        nameEn.contains('AtCoder Regular Contest')) {
      type = 'ARC';
      containerColor = colorScheme.tertiaryContainer;
      foregroundColor = colorScheme.onTertiaryContainer;
    } else if (nameJa.contains('Grand Contest') ||
        nameEn.contains('Grand Contest') ||
        nameJa.contains('AtCoder Grand Contest') ||
        nameEn.contains('AtCoder Grand Contest')) {
      type = 'AGC';
      containerColor = colorScheme.errorContainer;
      foregroundColor = colorScheme.onErrorContainer;
    } else if (nameJa.contains('Heuristic Contest') ||
        nameEn.contains('Heuristic Contest') ||
        nameJa.contains('AtCoder Heuristic Contest') ||
        nameEn.contains('AtCoder Heuristic Contest')) {
      type = 'AHC';
      containerColor = colorScheme.secondaryContainer;
      foregroundColor = colorScheme.onSecondaryContainer;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: containerColor.withValues(alpha: 0.78),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: foregroundColor.withValues(alpha: 0.18),
          width: 1,
        ),
      ),
      child: Text(
        type,
        style: theme.textTheme.bodySmall?.copyWith(
          color: foregroundColor,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
