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
  final _atcoderService = AtCoderService();

  String? _savedUsername;
  int? _currentRating;
  bool _isLoadingRecommendation = false;
  String? _recommendationErrorMessage;
  MapEntry<String, ProblemDifficulty>? _topRecommendation;
  String? _topRecommendationTitle;

  @override
  void initState() {
    super.initState();
    _loadSavedUsernameAndFetchRecommendation();
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
            style: TextStyle(
              color: color,
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _recommendationSection(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Text(
                  'おすすめ問題',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                const SizedBox(width: 8),
                IconButtonM3E(
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
            const SizedBox(height: 12),
            if (_savedUsername == null) ...[
              Text('AtCoderユーザー名が未設定です', style: theme.textTheme.bodyMedium),
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
                padding: EdgeInsets.symmetric(vertical: 12.0),
                child: Center(child: LoadingIndicatorM3E()),
              ),
            ] else if (_recommendationErrorMessage != null) ...[
              Text(
                _recommendationErrorMessage!,
                style: const TextStyle(color: Colors.red),
              ),
            ] else if (_topRecommendation == null) ...[
              Text('おすすめ問題が見つかりませんでした', style: theme.textTheme.bodyMedium),
            ] else ...[
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(
                  _topRecommendationTitle ?? _topRecommendation!.key,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                subtitle: _currentRating != null
                    ? Text(
                        '${_topRecommendation!.key} · あなたのレート: $_currentRating',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      )
                    : null,
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _difficultyBadge(_topRecommendation!.value.difficulty),
                    const SizedBox(width: 8),
                    const Icon(Icons.open_in_new),
                  ],
                ),
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
          const CustomSliverAppBar(isMainView: true, title: Text('ホーム')),
          SliverPadding(
            padding: const EdgeInsets.all(16.0),
            sliver: SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const NextABCContestWidget(),
                  const SizedBox(height: 24),
                  _recommendationSection(context),
                  const SizedBox(height: 16),
                  ButtonM3E(
                    icon: const Icon(Icons.web),
                    label: const Text('AtCoder Clans'),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const AtCoderClansScreen(),
                        ),
                      );
                    },
                    style: ButtonM3EStyle.filled,
                  ),
                  const SizedBox(height: 16),
                  // 他のウィジェットをここに追加可能
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
