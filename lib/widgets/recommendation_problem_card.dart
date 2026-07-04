import 'package:flutter/material.dart';

import '../utils/atcoder_colors.dart';
import '../utils/rating_utils.dart';

class RecommendationProblemCard extends StatelessWidget {
  const RecommendationProblemCard({
    super.key,
    required this.problemId,
    required this.title,
    required this.difficulty,
    required this.onTap,
  });

  final String problemId;
  final String title;
  final int? difficulty;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final borderRadius = BorderRadius.circular(8);

    return Card(
      elevation: 1,
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(borderRadius: borderRadius),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        borderRadius: borderRadius,
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: RecommendationProblemSummary(
            problemId: problemId,
            title: title,
            difficulty: difficulty,
          ),
        ),
      ),
    );
  }
}

class RecommendationProblemSummary extends StatelessWidget {
  const RecommendationProblemSummary({
    super.key,
    required this.problemId,
    required this.title,
    required this.difficulty,
    this.navigationIcon = Icons.chevron_right,
  });

  final String problemId;
  final String title;
  final int? difficulty;
  final IconData navigationIcon;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final textScale = MediaQuery.textScalerOf(context).scale(14) / 14;
        // Give long problem titles the full row when horizontal space or text
        // scaling would otherwise leave only a narrow text column.
        final stackMetadata = constraints.maxWidth < 300 || textScale > 1.3;

        if (stackMetadata) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _ProblemIdentity(problemId: problemId, title: title),
              const SizedBox(height: 10),
              Row(
                children: [
                  _DifficultyBadge(difficulty: difficulty),
                  const Spacer(),
                  _NavigationIcon(icon: navigationIcon),
                ],
              ),
            ],
          );
        }

        return Row(
          children: [
            Expanded(
              child: _ProblemIdentity(problemId: problemId, title: title),
            ),
            const SizedBox(width: 12),
            _DifficultyBadge(difficulty: difficulty),
            const SizedBox(width: 8),
            _NavigationIcon(icon: navigationIcon),
          ],
        );
      },
    );
  }
}

class _ProblemIdentity extends StatelessWidget {
  const _ProblemIdentity({required this.problemId, required this.title});

  final String problemId;
  final String title;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
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
          problemId,
          style: theme.textTheme.bodySmall?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}

class _DifficultyBadge extends StatelessWidget {
  const _DifficultyBadge({required this.difficulty});

  final int? difficulty;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    int? mappedDifficulty;
    if (difficulty != null) {
      final mapped = difficulty! <= 400
          ? RatingUtils.mapRating(difficulty!)
          : difficulty!.toDouble();
      mappedDifficulty = mapped.round();
    }
    final color = mappedDifficulty != null
        ? atcoderRatingToColor(mappedDifficulty)
        : const Color(0xFF808080);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        border: Border.all(color: color),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.bolt, size: 14, color: color),
          const SizedBox(width: 6),
          Text(
            mappedDifficulty?.toString() ?? 'N/A',
            style: theme.textTheme.labelMedium?.copyWith(
              color: color,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _NavigationIcon extends StatelessWidget {
  const _NavigationIcon({required this.icon});

  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Icon(
      icon,
      size: 20,
      color: Theme.of(context).colorScheme.onSurfaceVariant,
    );
  }
}
