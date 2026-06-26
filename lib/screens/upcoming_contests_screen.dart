import 'package:flutter/material.dart';
import 'package:m3e_collection/m3e_collection.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/contest.dart';
import '../providers/contest_provider.dart';

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
          tabs: const [
            Tab(text: 'ABC'),
            Tab(text: 'すべて'),
          ],
        ),
        actions: [
          IconButtonM3E(
            icon: const Icon(Icons.refresh),
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
          return _buildErrorState(
            provider.error!,
            () => provider.fetchUpcomingABCs(),
          );
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
          return _buildErrorState(
            provider.error!,
            () => provider.fetchUpcomingContests(),
          );
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
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
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
          child: LoadingIndicatorM3E(),
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

  Widget _buildErrorState(String error, VoidCallback onRetry) {
    return Center(
      child: _buildStateCard(
        icon: Icons.error_outline,
        title: 'エラーが発生しました',
        message: error,
        isError: true,
        child: Padding(
          padding: const EdgeInsets.only(top: 16),
          child: SizedBox(
            width: double.infinity,
            child: ButtonM3E(
              onPressed: onRetry,
              label: const Text('再試行'),
              style: ButtonM3EStyle.filled,
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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final foregroundColor = isError
        ? colorScheme.onErrorContainer
        : colorScheme.onSurfaceVariant;
    final iconBackground = isError
        ? colorScheme.errorContainer
        : colorScheme.primaryContainer;
    final iconColor = isError
        ? colorScheme.onErrorContainer
        : colorScheme.onPrimaryContainer;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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
                      color: iconBackground,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(icon, color: iconColor),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: isError ? foregroundColor : null,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          message,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: foregroundColor,
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
    );
  }

  Widget _buildContestCard(BuildContext context, Contest contest) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final borderRadius = BorderRadius.circular(16);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: borderRadius),
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
                      color: colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(12),
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
                          contest.startTimeWithWeekday,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          contest.status,
                          style: theme.textTheme.labelMedium?.copyWith(
                            color: colorScheme.primary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  _buildContestTypeChip(context, contest),
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
                  borderRadius: BorderRadius.circular(12),
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
    final colorScheme = theme.colorScheme;

    String type = 'その他';
    Color containerColor = colorScheme.surfaceContainerHighest;
    Color foregroundColor = colorScheme.onSurfaceVariant;

    // より確実な文字列マッチング
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
        borderRadius: BorderRadius.circular(12),
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
