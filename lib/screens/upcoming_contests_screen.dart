import 'package:flutter/material.dart';
import 'package:m3e_collection/m3e_collection.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/contest.dart';
import '../providers/contest_provider.dart';
import '../utils/responsive_layout.dart';
import '../widgets/shared/app_loading_indicator.dart';
import '../widgets/shared/app_state_card.dart';
import '../widgets/shared/responsive_action.dart';

class UpcomingContestsScreen extends StatefulWidget {
  const UpcomingContestsScreen({super.key});

  @override
  State<UpcomingContestsScreen> createState() => _UpcomingContestsScreenState();
}

class _UpcomingContestsScreenState extends State<UpcomingContestsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    // 初期化時にデータを取得
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ContestProvider>().refreshAll();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('今後のコンテスト'),
        bottom: TabBar(
          controller: _tabController,
          indicatorPadding: const EdgeInsets.symmetric(
            horizontal: 4,
            vertical: 6,
          ),
          splashBorderRadius: const BorderRadius.all(Radius.circular(12)),
          tabs: const [
            Tab(text: 'ABC'),
            Tab(text: 'すべて'),
          ],
        ),
        actions: [
          IconButtonM3E(
            icon: const Icon(Icons.refresh),
            tooltip: 'コンテスト情報を更新',
            onPressed: () => context.read<ContestProvider>().refreshAll(),
          ),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: [_buildABCTab(), _buildAllContestsTab()],
      ),
    );
  }

  Widget _buildABCTab() {
    return Consumer<ContestProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return _buildLoadingState('ABCの予定を取得しています');
        }

        if (provider.error != null) {
          return _buildErrorState(() => provider.fetchUpcomingABCs());
        }

        final contests = provider.upcomingABCs;
        if (contests.isEmpty) {
          return _buildEmptyState(
            title: '今後のABCが見つかりません',
            message: 'AtCoderの予定が公開されたあとに再度確認できます。',
          );
        }

        return _buildContestList(
          contests,
          onRefresh: () => provider.fetchUpcomingABCs(),
        );
      },
    );
  }

  Widget _buildAllContestsTab() {
    return Consumer<ContestProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return _buildLoadingState('コンテスト予定を取得しています');
        }

        if (provider.error != null) {
          return _buildErrorState(() => provider.fetchUpcomingContests());
        }

        final contests = provider.upcomingContests;
        if (contests.isEmpty) {
          return _buildEmptyState(
            title: '今後のコンテストが見つかりません',
            message: '予定が公開されたあとに再度確認できます。',
          );
        }

        return _buildContestList(
          contests,
          onRefresh: () => provider.fetchUpcomingContests(),
        );
      },
    );
  }

  Widget _buildContestList(
    List<Contest> contests, {
    required Future<void> Function() onRefresh,
  }) {
    return RefreshIndicator(
      onRefresh: onRefresh,
      child: ListView.builder(
        padding: ResponsiveLayout.listPadding(context),
        itemCount: contests.length,
        itemBuilder: (context, index) {
          return _buildContestCard(context, contests[index]);
        },
      ),
    );
  }

  Widget _buildLoadingState(String message) {
    return Center(
      child: _buildStateCard(
        icon: Icons.event_available,
        title: '読み込み中',
        message: message,
        child: const Padding(
          padding: EdgeInsets.only(top: 16),
          child: Center(
            child: AppLoadingIndicator(semanticsLabel: 'コンテスト予定を読み込み中'),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState({required String title, required String message}) {
    return Center(
      child: _buildStateCard(
        icon: Icons.event_busy,
        title: title,
        message: message,
      ),
    );
  }

  Widget _buildErrorState(VoidCallback onRetry) {
    return Center(
      child: _buildStateCard(
        icon: Icons.error_outline,
        title: 'コンテスト情報を取得できませんでした',
        // 通信層の例外文は環境依存で長くなるため、次の操作が分かる
        // 固定メッセージだけを状態カードに表示する。
        message: '通信状態を確認して、もう一度お試しください。',
        isError: true,
        child: Padding(
          padding: const EdgeInsets.only(top: 12),
          child: ResponsiveAction(
            child: ButtonM3E(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('再試行'),
              style: ButtonM3EStyle.tonal,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStateCard({
    required IconData icon,
    required String title,
    required String message,
    bool isError = false,
    Widget? child,
  }) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 640),
        child: AppStateCard(
          icon: icon,
          title: title,
          message: message,
          isError: isError,
          child: child,
        ),
      ),
    );
  }

  Widget _buildContestCard(BuildContext context, Contest contest) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final borderRadius = BorderRadius.circular(8);
    final contestColors = _contestColors(context, contest);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      color: Color.alphaBlend(
        contestColors.container.withValues(alpha: 0.22),
        colorScheme.surface,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: borderRadius,
        side: BorderSide(
          color: contestColors.foreground.withValues(alpha: 0.18),
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => _launchURL(contest.url),
        borderRadius: borderRadius,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: contestColors.container,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.event_available,
                      color: contestColors.foreground,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          contest.startTimeWithWeekday,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Wrap(
                          spacing: 8,
                          runSpacing: 4,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            Text(
                              _contestStatusLabel(contest.status),
                              style: theme.textTheme.labelMedium?.copyWith(
                                color: contestColors.foreground,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            _buildContestTypeChip(context, contest),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    Icons.open_in_new,
                    size: 18,
                    color: colorScheme.onSurfaceVariant,
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
                    _buildInfoRow(context, Icons.timer, contest.durationString),
                    if (contest.ratedRange != null) ...[
                      const SizedBox(height: 8),
                      _buildInfoRow(
                        context,
                        Icons.bar_chart,
                        'レート対象: ${contest.ratedRange}',
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContestTypeChip(BuildContext context, Contest contest) {
    final theme = Theme.of(context);
    final colors = _contestColors(context, contest);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: colors.container.withValues(alpha: 0.88),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: colors.foreground.withValues(alpha: 0.22),
          width: 1,
        ),
      ),
      child: Text(
        colors.label,
        style: theme.textTheme.bodySmall?.copyWith(
          color: colors.foreground,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  String _contestStatusLabel(String status) {
    switch (status.toLowerCase()) {
      case 'upcoming':
        return '開催予定';
      case 'running':
        return '開催中';
      case 'finished':
        return '終了';
      default:
        return status;
    }
  }

  ({String label, Color container, Color foreground}) _contestColors(
    BuildContext context,
    Contest contest,
  ) {
    final colors = Theme.of(context).colorScheme;
    final names = '${contest.nameJa} ${contest.nameEn}';

    if (contest.isABC || names.contains('Beginner Contest')) {
      return (
        label: 'ABC',
        container: colors.primaryContainer,
        foreground: colors.onPrimaryContainer,
      );
    }
    if (names.contains('Regular Contest')) {
      return (
        label: 'ARC',
        container: colors.tertiaryContainer,
        foreground: colors.onTertiaryContainer,
      );
    }
    if (names.contains('Grand Contest')) {
      return (
        label: 'AGC',
        container: colors.errorContainer,
        foreground: colors.onErrorContainer,
      );
    }
    if (names.contains('Heuristic Contest')) {
      return (
        label: 'AHC',
        container: colors.secondaryContainer,
        foreground: colors.onSecondaryContainer,
      );
    }
    return (
      label: 'その他',
      container: colors.surfaceContainerHighest,
      foreground: colors.onSurfaceVariant,
    );
  }

  Widget _buildInfoRow(BuildContext context, IconData icon, String text) {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      children: [
        Icon(icon, size: 16, color: colorScheme.onSurfaceVariant),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w500),
          ),
        ),
      ],
    );
  }

  Future<void> _launchURL(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('URLを開けませんでした: $url')));
      }
    }
  }
}
