import 'package:flutter/material.dart';
import 'package:m3e_collection/m3e_collection.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shojin_app/screens/atcoder_clans_screen.dart';
import 'package:shojin_app/screens/recommend_screen.dart';

import '../models/problem_difficulty.dart';
import '../screens/problem_detail_screen.dart';
import '../services/atcoder_service.dart';
import '../utils/atcoder_colors.dart';
import '../utils/rating_utils.dart';
import '../widgets/next_abc_contest_widget.dart';
import '../widgets/shared/custom_sliver_app_bar.dart';

class NewHomeScreen extends StatefulWidget {
  const NewHomeScreen({super.key});

  @override
  State<NewHomeScreen> createState() => _NewHomeScreenState();
}

class _NewHomeScreenState extends State<NewHomeScreen> {
  static const _widgetOrderKey = 'home_widget_order';
  static const _hiddenWidgetsKey = 'home_hidden_widgets';
  static const _defaultWidgetOrder = ['next_abc', 'recommendation', 'clans'];

  final _atcoderService = AtCoderService();

  String? _savedUsername;
  int? _currentRating;
  bool _isLoadingRecommendation = false;
  String? _recommendationErrorMessage;
  MapEntry<String, ProblemDifficulty>? _topRecommendation;
  String? _topRecommendationTitle;
  List<String> _widgetOrder = [..._defaultWidgetOrder];
  Set<String> _hiddenWidgets = {};

  @override
  void initState() {
    super.initState();
    _loadSavedUsernameAndFetchRecommendation();
    _loadWidgetPreferences();
  }

  Future<void> _loadWidgetPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    final savedOrder = prefs.getStringList(_widgetOrderKey) ?? const [];
    final normalizedOrder = [
      ...savedOrder.where(_defaultWidgetOrder.contains),
      ..._defaultWidgetOrder.where((id) => !savedOrder.contains(id)),
    ];
    if (!mounted) return;
    setState(() {
      _widgetOrder = normalizedOrder;
      _hiddenWidgets = (prefs.getStringList(_hiddenWidgetsKey) ?? const [])
          .where(_defaultWidgetOrder.contains)
          .toSet();
    });
  }

  Future<void> _saveWidgetPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_widgetOrderKey, _widgetOrder);
    await prefs.setStringList(_hiddenWidgetsKey, _hiddenWidgets.toList());
  }

  String _widgetLabel(String id) {
    switch (id) {
      case 'next_abc':
        return '次回のABC';
      case 'recommendation':
        return 'おすすめ問題';
      case 'clans':
        return 'AtCoder Clans';
      default:
        return id;
    }
  }

  IconData _widgetIcon(String id) {
    switch (id) {
      case 'next_abc':
        return Icons.event_available;
      case 'recommendation':
        return Icons.recommend;
      case 'clans':
        return Icons.web;
      default:
        return Icons.widgets;
    }
  }

  Future<void> _showWidgetManager() async {
    var draftOrder = [..._widgetOrder];
    var draftHidden = {..._hiddenWidgets};

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) => StatefulBuilder(
        builder: (context, setSheetState) {
          final theme = Theme.of(context);
          final colorScheme = theme.colorScheme;

          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'ホームをカスタマイズ',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'ドラッグで並べ替え、スイッチで表示を切り替えます。',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Flexible(
                    child: ReorderableListView.builder(
                      shrinkWrap: true,
                      itemCount: draftOrder.length,
                      onReorderItem: (oldIndex, newIndex) {
                        setSheetState(() {
                          final item = draftOrder.removeAt(oldIndex);
                          draftOrder.insert(newIndex, item);
                        });
                      },
                      itemBuilder: (context, index) {
                        final id = draftOrder[index];
                        final visible = !draftHidden.contains(id);
                        return Padding(
                          key: ValueKey(id),
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Material(
                            color: visible
                                ? colorScheme.primaryContainer.withValues(
                                    alpha: 0.22,
                                  )
                                : colorScheme.surfaceContainerHighest
                                      .withValues(alpha: 0.45),
                            borderRadius: BorderRadius.circular(14),
                            child: SwitchListTile(
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 2,
                              ),
                              secondary: Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: visible
                                      ? colorScheme.primaryContainer
                                      : colorScheme.surfaceContainerHighest,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Center(
                                  child: Icon(
                                    _widgetIcon(id),
                                    color: visible
                                        ? colorScheme.onPrimaryContainer
                                        : colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              ),
                              title: Text(
                                _widgetLabel(id),
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  fontWeight: visible
                                      ? FontWeight.w700
                                      : FontWeight.w500,
                                ),
                              ),
                              subtitle: Text(
                                visible ? 'ホームに表示中' : '非表示',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: colorScheme.onSurfaceVariant,
                                ),
                              ),
                              value: visible,
                              onChanged: (visible) {
                                setSheetState(() {
                                  visible
                                      ? draftHidden.remove(id)
                                      : draftHidden.add(id);
                                });
                              },
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ButtonM3E(
                      style: ButtonM3EStyle.filled,
                      label: const Text('保存'),
                      onPressed: () {
                        setState(() {
                          _widgetOrder = draftOrder;
                          _hiddenWidgets = draftHidden;
                        });
                        _saveWidgetPreferences();
                        Navigator.pop(context);
                      },
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildHomeWidget(String id) {
    switch (id) {
      case 'next_abc':
        return const NextABCContestWidget(key: ValueKey('next_abc'));
      case 'recommendation':
        return KeyedSubtree(
          key: const ValueKey('recommendation'),
          child: _recommendationSection(context),
        );
      case 'clans':
        return _quickLinkCard(
          key: const ValueKey('clans'),
          icon: Icons.travel_explore,
          title: 'AtCoder Clans',
          subtitle: 'コンテスト情報や解説記事を探す',
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const AtCoderClansScreen(),
              ),
            );
          },
        );
      default:
        return const SizedBox.shrink();
    }
  }

  Future<void> _loadSavedUsernameAndFetchRecommendation() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final saved = prefs.getString('atcoder_username');
      if (!mounted) return;
      setState(() {
        _savedUsername = (saved != null && saved.isNotEmpty) ? saved : null;
      });
      if (_savedUsername != null) {
        await _fetchTopRecommendation();
      }
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _savedUsername = null;
      });
    }
  }

  Future<void> _fetchTopRecommendation() async {
    final username = _savedUsername;
    if (username == null || username.isEmpty) return;

    setState(() {
      _isLoadingRecommendation = true;
      _recommendationErrorMessage = null;
      _topRecommendation = null;
      _topRecommendationTitle = null;
      _currentRating = null;
    });

    try {
      const lowerDelta = -100;
      const upperDelta = 100;

      final ratingInfo = await _atcoderService.fetchAtcoderRatingInfo(username);
      if (ratingInfo == null) {
        throw Exception('ユーザーが見つからないか、レーティングがありません');
      }

      if (mounted) {
        setState(() {
          _currentRating = ratingInfo.latestRating;
        });
      }

      final results = await Future.wait([
        _atcoderService.fetchProblemDifficulties(),
        _atcoderService.fetchProblemTitles(),
      ]);
      final allProblems = results[0] as Map<String, ProblemDifficulty>;
      final problemTitles = results[1] as Map<String, String>;
      final trueRating = RatingUtils.trueRating(
        rating: ratingInfo.latestRating,
        contests: ratingInfo.contestCount,
      );

      final recommended = allProblems.entries.where((entry) {
        final difficulty = entry.value.difficulty;
        if (difficulty == null) return false;
        final mappedDiff = difficulty <= 400
            ? RatingUtils.mapRating(difficulty)
            : difficulty.toDouble();
        return mappedDiff >= trueRating + lowerDelta &&
            mappedDiff <= trueRating + upperDelta;
      }).toList();

      recommended.sort((a, b) {
        final ad = a.value.difficulty!;
        final bd = b.value.difficulty!;
        final mad = ad <= 400 ? RatingUtils.mapRating(ad) : ad.toDouble();
        final mbd = bd <= 400 ? RatingUtils.mapRating(bd) : bd.toDouble();
        final da = (mad - trueRating).abs();
        final db = (mbd - trueRating).abs();
        final cmp = da.compareTo(db);
        if (cmp != 0) return cmp;
        return a.value.difficulty!.compareTo(b.value.difficulty!);
      });

      if (!mounted) return;
      setState(() {
        _topRecommendation = recommended.isNotEmpty ? recommended.first : null;
        _topRecommendationTitle = _topRecommendation == null
            ? null
            : problemTitles[_topRecommendation!.key];
      });
    } catch (e) {
      if (mounted) {
        setState(() {
          _recommendationErrorMessage = e.toString();
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingRecommendation = false;
        });
      }
    }
  }

  Widget _difficultyBadge(int? difficulty) {
    final theme = Theme.of(context);
    int? mappedInt;
    if (difficulty != null) {
      final mapped = difficulty <= 400
          ? RatingUtils.mapRating(difficulty)
          : difficulty.toDouble();
      mappedInt = mapped.round();
    }
    final color = (mappedInt != null)
        ? atcoderRatingToColor(mappedInt)
        : const Color(0xFF808080);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        border: Border.all(color: color, width: 1),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.bolt, size: 14, color: color),
          const SizedBox(width: 6),
          Text(
            mappedInt?.toString() ?? 'N/A',
            style: theme.textTheme.labelMedium?.copyWith(
              color: color,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _quickLinkCard({
    required Key key,
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onPressed,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final borderRadius = BorderRadius.circular(16);

    return Card(
      key: key,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: borderRadius),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        borderRadius: borderRadius,
        onTap: onPressed,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
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
                      subtitle,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: colorScheme.outline,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _messagePanel(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String message,
    bool isError = false,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final backgroundColor = isError
        ? colorScheme.errorContainer
        : colorScheme.surfaceContainerHighest.withValues(alpha: 0.5);
    final foregroundColor = isError
        ? colorScheme.onErrorContainer
        : colorScheme.onSurfaceVariant;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: foregroundColor),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.titleSmall?.copyWith(
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
    );
  }

  Widget _recommendationSection(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final borderRadius = BorderRadius.circular(16);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: borderRadius),
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: colorScheme.secondaryContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.auto_awesome,
                    color: colorScheme.onSecondaryContainer,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'おすすめ問題',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        _currentRating == null
                            ? 'レートに近い問題を表示'
                            : 'あなたのレート: $_currentRating',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButtonM3E(
                  tooltip: 'おすすめ問題を開く',
                  icon: Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                    color: colorScheme.onSurfaceVariant,
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const RecommendScreen(),
                      ),
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (_savedUsername == null) ...[
              _messagePanel(
                context,
                icon: Icons.person_search,
                title: 'AtCoderユーザー名が未設定です',
                message: 'ユーザー名を設定すると、今のレートに近い問題をすぐ確認できます。',
              ),
              const SizedBox(height: 12),
              ButtonM3E(
                icon: const Icon(Icons.recommend),
                label: const Text('おすすめ問題を開く'),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const RecommendScreen(),
                    ),
                  );
                },
                style: ButtonM3EStyle.filled,
              ),
            ] else if (_isLoadingRecommendation) ...[
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 20.0),
                child: Center(child: LoadingIndicatorM3E()),
              ),
            ] else if (_recommendationErrorMessage != null) ...[
              _messagePanel(
                context,
                icon: Icons.error_outline,
                title: 'おすすめ問題を取得できませんでした',
                message: _recommendationErrorMessage!,
                isError: true,
              ),
            ] else if (_topRecommendation == null) ...[
              _messagePanel(
                context,
                icon: Icons.search_off,
                title: 'おすすめ問題が見つかりませんでした',
                message: '条件に合う問題がない可能性があります。おすすめ画面で範囲を調整できます。',
              ),
            ] else ...[
              InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ProblemDetailScreen(
                        problemIdToLoad: _topRecommendation!.key,
                        onProblemChanged: (_) {},
                      ),
                    ),
                  );
                },
                child: Container(
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
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _topRecommendationTitle ??
                                  _topRecommendation!.key,
                              style: theme.textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _topRecommendation!.key,
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
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          _difficultyBadge(
                            _topRecommendation!.value.difficulty,
                          ),
                          const SizedBox(height: 8),
                          Icon(
                            Icons.open_in_new,
                            size: 18,
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          CustomSliverAppBar(
            isMainView: true,
            title: const Text('ホーム'),
            actions: [
              IconButtonM3E(
                tooltip: 'ホームをカスタマイズ',
                icon: const Icon(Icons.dashboard_customize_outlined),
                onPressed: _showWidgetManager,
              ),
            ],
          ),
          SliverPadding(
            padding: const EdgeInsets.all(16.0),
            sliver: SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: _widgetOrder
                    .where((id) => !_hiddenWidgets.contains(id))
                    .expand(
                      (id) => [
                        _buildHomeWidget(id),
                        const SizedBox(height: 16),
                      ],
                    )
                    .toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
