import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show listEquals, setEquals;
import 'package:m3e_collection/m3e_collection.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shojin_app/screens/atcoder_clans_screen.dart';
import 'package:shojin_app/screens/recommend_screen.dart';

import '../models/problem_difficulty.dart';
import '../services/atcoder_service.dart';
import '../utils/rating_utils.dart';
import '../utils/responsive_layout.dart';
import '../widgets/next_abc_contest_widget.dart';
import '../widgets/recommendation_problem_card.dart';
import '../widgets/shared/custom_sliver_app_bar.dart';
import '../widgets/shared/app_loading_indicator.dart';
import '../widgets/shared/responsive_action.dart';

class NewHomeScreen extends StatefulWidget {
  const NewHomeScreen({
    super.key,
    this.atCoderService,
    this.isSelected = true,
    this.onProblemSelected,
  });

  final AtCoderService? atCoderService;
  final bool isSelected;
  final ValueChanged<String>? onProblemSelected;

  @override
  State<NewHomeScreen> createState() => _NewHomeScreenState();
}

class _NewHomeScreenState extends State<NewHomeScreen>
    with WidgetsBindingObserver {
  static const _widgetOrderKey = 'home_widget_order';
  static const _hiddenWidgetsKey = 'home_hidden_widgets';
  static const _defaultWidgetOrder = ['next_abc', 'recommendation', 'clans'];

  late final AtCoderService _atcoderService;

  String? _savedUsername;
  int? _currentRating;
  bool _isLoadingRecommendation = false;
  String? _recommendationErrorMessage;
  MapEntry<String, ProblemDifficulty>? _topRecommendation;
  String? _topRecommendationTitle;
  List<String> _widgetOrder = [..._defaultWidgetOrder];
  Set<String> _hiddenWidgets = {};
  bool _areWidgetPreferencesLoaded = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _atcoderService = widget.atCoderService ?? AtCoderService();
    _loadSavedUsernameAndFetchRecommendation();
    _loadWidgetPreferences();
  }

  @override
  void didUpdateWidget(covariant NewHomeScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    // タブは破棄されず保持されるため、設定タブから戻った時だけ永続値を
    // 再読込する。これがないと保存済みユーザー名が次回起動まで反映されない。
    if (widget.isSelected && !oldWidget.isSelected) {
      _loadSavedUsernameAndFetchRecommendation();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _loadSavedUsernameAndFetchRecommendation();
    }
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
      _areWidgetPreferencesLoaded = true;
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
    final originalOrder = [..._widgetOrder];
    final originalHidden = {..._hiddenWidgets};
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
          final hasChanges =
              !listEquals(draftOrder, originalOrder) ||
              !setEquals(draftHidden, originalHidden);
          final isDefault =
              listEquals(draftOrder, _defaultWidgetOrder) &&
              draftHidden.isEmpty;

          return SafeArea(
            child: Center(
              child: ConstrainedBox(
                // ボトムシートはデスクトップでも設定項目同士の視線移動が
                // 大きくなりすぎない幅に留める。
                constraints: const BoxConstraints(maxWidth: 640),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              'ホームをカスタマイズ',
                              style: theme.textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          IconButtonM3E(
                            tooltip: '初期状態に戻す',
                            icon: const Icon(Icons.restart_alt),
                            onPressed: isDefault
                                ? null
                                : () {
                                    setSheetState(() {
                                      draftOrder = [..._defaultWidgetOrder];
                                      draftHidden.clear();
                                    });
                                  },
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Flexible(
                        child: ReorderableListView.builder(
                          shrinkWrap: true,
                          buildDefaultDragHandles: false,
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
                            return ReorderableDelayedDragStartListener(
                              key: ValueKey(id),
                              index: index,
                              child: Padding(
                                padding: const EdgeInsets.only(bottom: 8),
                                child: Material(
                                  color: visible
                                      ? colorScheme.primaryContainer.withValues(
                                          alpha: 0.22,
                                        )
                                      : colorScheme.surfaceContainerHighest
                                            .withValues(alpha: 0.45),
                                  borderRadius: BorderRadius.circular(8),
                                  child: SwitchListTile(
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 2,
                                    ),
                                    secondary: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        SizedBox(
                                          key: ValueKey('home-drag-$id'),
                                          child: Tooltip(
                                            message: '並べ替え',
                                            child: SizedBox(
                                              // アイコンは控えめなまま、Androidで
                                              // 掴みやすい48dpの操作領域を確保する。
                                              width: 48,
                                              height: 48,
                                              child: Icon(
                                                Icons.drag_handle,
                                                color: colorScheme
                                                    .onSurfaceVariant,
                                              ),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 4),
                                        Container(
                                          width: 40,
                                          height: 40,
                                          decoration: BoxDecoration(
                                            color: visible
                                                ? colorScheme.primaryContainer
                                                : colorScheme
                                                      .surfaceContainerHighest,
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                          ),
                                          child: Center(
                                            child: Icon(
                                              _widgetIcon(id),
                                              color: visible
                                                  ? colorScheme
                                                        .onPrimaryContainer
                                                  : colorScheme
                                                        .onSurfaceVariant,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    title: Text(
                                      _widgetLabel(id),
                                      style: theme.textTheme.bodyMedium
                                          ?.copyWith(
                                            fontWeight: visible
                                                ? FontWeight.w700
                                                : FontWeight.w500,
                                          ),
                                    ),
                                    subtitle: Text(
                                      visible ? 'ホームに表示中' : '非表示',
                                      style: theme.textTheme.bodySmall
                                          ?.copyWith(
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
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 12),
                      ResponsiveAction(
                        child: ButtonM3E(
                          style: ButtonM3EStyle.filled,
                          label: const Text('保存'),
                          onPressed: !hasChanges
                              ? null
                              : () async {
                                  setState(() {
                                    _widgetOrder = [...draftOrder];
                                    _hiddenWidgets = {...draftHidden};
                                  });
                                  await _saveWidgetPreferences();
                                  if (!mounted || !context.mounted) return;
                                  Navigator.pop(context);
                                  final messenger = ScaffoldMessenger.of(
                                    this.context,
                                  );
                                  messenger.hideCurrentSnackBar();
                                  messenger.showSnackBar(
                                    SnackBar(
                                      content: const Text('ホームを更新しました'),
                                      action: SnackBarAction(
                                        label: '元に戻す',
                                        onPressed: () async {
                                          setState(() {
                                            _widgetOrder = [...originalOrder];
                                            _hiddenWidgets = {
                                              ...originalHidden,
                                            };
                                          });
                                          await _saveWidgetPreferences();
                                        },
                                      ),
                                    ),
                                  );
                                },
                        ),
                      ),
                    ],
                  ),
                ),
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
      final saved = prefs.getString('atcoder_username')?.trim();
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
    } catch (_) {
      if (mounted) {
        setState(() {
          // 通信ライブラリの例外文は長く不安定なので、カードには次の操作が
          // 分かる固定文だけを表示する。
          _recommendationErrorMessage = '通信状態を確認して、もう一度お試しください。';
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

  Widget _quickLinkCard({
    required Key key,
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onPressed,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final borderRadius = BorderRadius.circular(8);

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
                  borderRadius: BorderRadius.circular(8),
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
        borderRadius: BorderRadius.circular(8),
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

  void _openRecommendations() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            RecommendScreen(onProblemSelected: widget.onProblemSelected),
      ),
    );
  }

  void _openProblem(String problemId) {
    final onProblemSelected = widget.onProblemSelected;
    if (onProblemSelected != null) {
      onProblemSelected(problemId);
      return;
    }
    _openRecommendations();
  }

  Widget _recommendationSection(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final borderRadius = BorderRadius.circular(8);

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
                    borderRadius: BorderRadius.circular(8),
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
                  onPressed: _openRecommendations,
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
              ResponsiveAction(
                child: ButtonM3E(
                  icon: const Icon(Icons.recommend),
                  label: const Text('おすすめ問題を開く'),
                  onPressed: _openRecommendations,
                  style: ButtonM3EStyle.filled,
                ),
              ),
            ] else if (_isLoadingRecommendation) ...[
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 20.0),
                child: Center(
                  child: AppLoadingIndicator(semanticsLabel: 'おすすめ問題を読み込み中'),
                ),
              ),
            ] else if (_recommendationErrorMessage != null) ...[
              _messagePanel(
                context,
                icon: Icons.error_outline,
                title: 'おすすめ問題を取得できませんでした',
                message: _recommendationErrorMessage!,
                isError: true,
              ),
              const SizedBox(height: 12),
              ResponsiveAction(
                child: ButtonM3E(
                  icon: const Icon(Icons.refresh),
                  label: const Text('再試行'),
                  onPressed: _fetchTopRecommendation,
                  style: ButtonM3EStyle.tonal,
                ),
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
                borderRadius: BorderRadius.circular(8),
                onTap: () => _openProblem(_topRecommendation!.key),
                child: Container(
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
                  child: RecommendationProblemSummary(
                    problemId: _topRecommendation!.key,
                    title: _topRecommendationTitle ?? _topRecommendation!.key,
                    difficulty: _topRecommendation!.value.difficulty,
                    navigationIcon: Icons.open_in_new,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyHomeState(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      elevation: 2,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
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
                    Icons.space_dashboard_outlined,
                    color: colorScheme.onPrimaryContainer,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    '表示中のウィジェットはありません',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ResponsiveAction(
              child: ButtonM3E(
                style: ButtonM3EStyle.filled,
                icon: const Icon(Icons.dashboard_customize_outlined),
                label: const Text('表示を設定'),
                onPressed: _showWidgetManager,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final horizontalInset = ResponsiveLayout.horizontalPadding(context);
    final visibleWidgetIds = _widgetOrder
        .where((id) => !_hiddenWidgets.contains(id))
        .toList();

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
            padding: EdgeInsets.fromLTRB(
              horizontalInset,
              16,
              horizontalInset,
              ResponsiveLayout.bottomNavigationClearance(context),
            ),
            sliver: SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: !_areWidgetPreferencesLoaded
                    ? const [
                        Padding(
                          padding: EdgeInsets.symmetric(vertical: 32),
                          child: Center(
                            child: AppLoadingIndicator(
                              semanticsLabel: 'ホーム設定を読み込み中',
                            ),
                          ),
                        ),
                      ]
                    : visibleWidgetIds.isEmpty
                    ? [_buildEmptyHomeState(context)]
                    : visibleWidgetIds
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
