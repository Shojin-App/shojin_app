import 'package:flutter/material.dart';
import 'package:m3e_collection/m3e_collection.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/problem_difficulty.dart';
import '../services/atcoder_service.dart';
import '../utils/atcoder_colors.dart';
import '../utils/rating_utils.dart';
import 'problem_detail_screen.dart';

class RecommendScreen extends StatefulWidget {
  const RecommendScreen({super.key});

  @override
  State<RecommendScreen> createState() => _RecommendScreenState();
}

class _RecommendScreenState extends State<RecommendScreen> {
  final _atcoderService = AtCoderService();
  final _usernameController = TextEditingController();
  final _lowerDeltaController = TextEditingController();
  final _upperDeltaController = TextEditingController();
  List<MapEntry<String, ProblemDifficulty>> _recommendedProblems = [];
  bool _isLoading = false;
  String? _errorMessage;
  String? _savedUsername; // 設定済みユーザー名
  int? _currentRating; // 取得したレート（表示用: 最新レート）
  Map<String, String> _problemTitles = {};

  // AtCoder カラー判定
  Color _ratingColor(int rating) {
    if (rating >= 2800) return const Color(0xFFFF0000); // 赤
    if (rating >= 2400) return const Color(0xFFFF8000); // 橙
    if (rating >= 2000) return const Color(0xFFC0C000); // 黄
    if (rating >= 1600) return const Color(0xFF0000FF); // 青
    if (rating >= 1200) return const Color(0xFF00C0C0); // 水
    if (rating >= 800) return const Color(0xFF008000); // 緑
    if (rating >= 400) return const Color(0xFF804000); // 茶
    return const Color(0xFF808080); // 灰
  }

  // レート表示用バッジ
  Widget _ratingBadge(int rating) {
    final theme = Theme.of(context);
    final color = _ratingColor(rating);
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
          Icon(Icons.emoji_events, size: 14, color: color),
          const SizedBox(width: 6),
          Text(
            rating.toString(),
            style: theme.textTheme.labelMedium?.copyWith(
              color: color,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  // Difficulty 表示用バッジ（補正後diffで表示。色も補正後ベース）
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

  @override
  void initState() {
    super.initState();
    // 推薦条件のデフォルト（±100）
    _lowerDeltaController.text = '-100';
    _upperDeltaController.text = '100';
    _loadSavedUsername();
  }

  Future<void> _loadSavedUsername() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final saved = prefs.getString('atcoder_username');
      if (!mounted) return;
      setState(() {
        _savedUsername = (saved != null && saved.isNotEmpty) ? saved : null;
        if (_savedUsername != null) {
          _usernameController.text = _savedUsername!;
        }
      });
      // ユーザー名が既に設定されている場合は自動で推薦を取得
      if (mounted && _savedUsername != null && _savedUsername!.isNotEmpty) {
        // 少し遅延してビルド完了後に実行（安全策）
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted && !_isLoading && _recommendedProblems.isEmpty) {
            _getRecommendations();
          }
        });
      }
    } catch (_) {
      // ignore
    }
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _lowerDeltaController.dispose();
    _upperDeltaController.dispose();
    super.dispose();
  }

  Future<void> _getRecommendations() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _recommendedProblems = [];
      _currentRating = null;
      _problemTitles = {};
    });

    try {
      // 条件の取得とバリデーション
      int lowerDelta = int.tryParse(_lowerDeltaController.text.trim()) ?? -100;
      int upperDelta = int.tryParse(_upperDeltaController.text.trim()) ?? 100;
      if (lowerDelta > upperDelta) {
        // 入力が逆の場合は入れ替え
        final tmp = lowerDelta;
        lowerDelta = upperDelta;
        upperDelta = tmp;
      }

      // 事前に設定済みのユーザー名を優先
      final username = (_savedUsername != null && _savedUsername!.isNotEmpty)
          ? _savedUsername!
          : _usernameController.text;
      if (username.isEmpty) {
        throw Exception('ユーザー名を入力してください');
      }

      final ratingInfo = await _atcoderService.fetchAtcoderRatingInfo(username);
      if (ratingInfo == null) {
        throw Exception('ユーザーが見つからないか、レーティングがありません');
      }

      // レートを保存してUIに表示
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
      // TrueRating を計算（数式(10)）
      final trueRating = RatingUtils.trueRating(
        rating: ratingInfo.latestRating,
        contests: ratingInfo.contestCount,
      );

      final recommended = allProblems.entries.where((entry) {
        final difficulty = entry.value.difficulty;
        if (difficulty == null) return false;
        // 400 以下の diff は mapRating で補正（比較用のみ）
        final mappedDiff = difficulty <= 400
            ? RatingUtils.mapRating(difficulty)
            : difficulty.toDouble();
        return mappedDiff >= trueRating + lowerDelta &&
            mappedDiff <= trueRating + upperDelta;
      }).toList();

      // 自分のレートに近い順に並べ替え（差の絶対値の昇順）
      recommended.sort((a, b) {
        final ad = a.value.difficulty!;
        final bd = b.value.difficulty!;
        final mad = ad <= 400 ? RatingUtils.mapRating(ad) : ad.toDouble();
        final mbd = bd <= 400 ? RatingUtils.mapRating(bd) : bd.toDouble();
        final da = (mad - trueRating).abs();
        final db = (mbd - trueRating).abs();
        final cmp = da.compareTo(db);
        if (cmp != 0) return cmp;
        // 差が同じ場合は難易度の昇順で安定化
        return a.value.difficulty!.compareTo(b.value.difficulty!);
      });

      if (!mounted) return;
      setState(() {
        _recommendedProblems = recommended;
        _problemTitles = problemTitles;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = e.toString().replaceFirst('Exception: ', '');
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  InputDecoration _inputDecoration(
    BuildContext context, {
    required String labelText,
    String? hintText,
    required IconData prefixIcon,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: colorScheme.outlineVariant),
    );

    return InputDecoration(
      labelText: labelText,
      hintText: hintText,
      prefixIcon: Icon(prefixIcon),
      filled: true,
      fillColor: colorScheme.surfaceContainerHighest.withValues(alpha: 0.35),
      border: border,
      enabledBorder: border,
      focusedBorder: border.copyWith(
        borderSide: BorderSide(color: colorScheme.primary, width: 1.6),
      ),
    );
  }

  Widget _buildRecommendationControls(BuildContext context) {
    final lowerField = TextField(
      controller: _lowerDeltaController,
      keyboardType: const TextInputType.numberWithOptions(signed: true),
      textInputAction: TextInputAction.next,
      decoration: _inputDecoration(
        context,
        labelText: '下限差',
        hintText: '-100',
        prefixIcon: Icons.arrow_downward,
      ),
    );
    final upperField = TextField(
      controller: _upperDeltaController,
      keyboardType: const TextInputType.numberWithOptions(signed: true),
      textInputAction: TextInputAction.done,
      onSubmitted: (_) {
        if (!_isLoading) _getRecommendations();
      },
      decoration: _inputDecoration(
        context,
        labelText: '上限差',
        hintText: '100',
        prefixIcon: Icons.arrow_upward,
      ),
    );
    final submitButton = ButtonM3E(
      onPressed: _isLoading ? null : _getRecommendations,
      icon: const Icon(Icons.tune),
      label: const Text('条件を適用'),
      style: ButtonM3EStyle.filled,
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 560) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Expanded(child: lowerField),
                  const SizedBox(width: 12),
                  Expanded(child: upperField),
                ],
              ),
              const SizedBox(height: 12),
              submitButton,
            ],
          );
        }

        return Row(
          children: [
            Expanded(child: lowerField),
            const SizedBox(width: 12),
            Expanded(child: upperField),
            const SizedBox(width: 12),
            submitButton,
          ],
        );
      },
    );
  }

  Widget _buildSettingsPanel(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.manage_search,
                    color: colorScheme.onPrimaryContainer,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '推薦条件',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _savedUsername == null
                            ? 'AtCoderユーザー名と難易度範囲を指定'
                            : '$_savedUsername のレート周辺を検索',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                if (_currentRating != null) _ratingBadge(_currentRating!),
              ],
            ),
            const SizedBox(height: 16),
            if (_savedUsername == null) ...[
              TextField(
                controller: _usernameController,
                decoration: _inputDecoration(
                  context,
                  labelText: 'AtCoderユーザー名',
                  prefixIcon: Icons.person_outline,
                ),
              ),
              const SizedBox(height: 12),
            ] else ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest.withValues(
                    alpha: 0.45,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.person,
                      size: 20,
                      color: colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        _savedUsername!,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    ButtonM3E(
                      onPressed: () async {
                        final prefs = await SharedPreferences.getInstance();
                        await prefs.remove('atcoder_username');
                        if (!mounted) return;
                        setState(() {
                          _savedUsername = null;
                          _usernameController.clear();
                          _currentRating = null;
                        });
                      },
                      label: const Text('変更'),
                      style: ButtonM3EStyle.text,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
            ],
            _buildRecommendationControls(context),
            if (_savedUsername == null) ...[
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ButtonM3E(
                  onPressed: _isLoading ? null : _getRecommendations,
                  icon: const Icon(Icons.auto_awesome),
                  label: const Text('おすすめを取得'),
                  style: ButtonM3EStyle.filled,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildMessageState(
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
        : colorScheme.surfaceContainerHighest.withValues(alpha: 0.45);
    final foregroundColor = isError
        ? colorScheme.onErrorContainer
        : colorScheme.onSurfaceVariant;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16),
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

  Widget _buildProblemCard(
    BuildContext context,
    MapEntry<String, ProblemDifficulty> problem,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final borderRadius = BorderRadius.circular(16);
    final title = _problemTitles[problem.key] ?? problem.key;

    return Card(
      elevation: 1,
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(borderRadius: borderRadius),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        borderRadius: borderRadius,
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ProblemDetailScreen(
                problemIdToLoad: problem.key,
                onProblemChanged: (_) {},
              ),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      problem.key,
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
                  _difficultyBadge(problem.value.difficulty),
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
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarM3E(title: const Text('おすすめ問題')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildSettingsPanel(context),
            const SizedBox(height: 16),
            if (_isLoading)
              const Expanded(child: Center(child: LoadingIndicatorM3E()))
            else if (_errorMessage != null)
              Expanded(
                child: Align(
                  alignment: Alignment.topCenter,
                  child: _buildMessageState(
                    context,
                    icon: Icons.error_outline,
                    title: 'おすすめ問題を取得できませんでした',
                    message: _errorMessage!,
                    isError: true,
                  ),
                ),
              )
            else if (_recommendedProblems.isEmpty)
              Expanded(
                child: Align(
                  alignment: Alignment.topCenter,
                  child: _buildMessageState(
                    context,
                    icon: Icons.search_off,
                    title: '条件に合う問題はまだ表示されていません',
                    message: 'ユーザー名を入力するか、難易度範囲を調整して取得してください。',
                  ),
                ),
              )
            else
              Expanded(
                child: ListView.builder(
                  padding: EdgeInsets.zero,
                  itemCount: _recommendedProblems.length,
                  itemBuilder: (context, index) {
                    final problem = _recommendedProblems[index];
                    return _buildProblemCard(context, problem);
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}
