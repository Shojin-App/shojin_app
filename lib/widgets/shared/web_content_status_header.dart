import 'package:flutter/material.dart';
import 'package:m3e_collection/m3e_collection.dart';

class WebContentStatusHeader extends StatelessWidget {
  const WebContentStatusHeader({
    super.key,
    required this.statusMessage,
    required this.detail,
    required this.icon,
    required this.loadingProgress,
    required this.isLoading,
    required this.hasError,
    required this.progressSemanticsLabel,
    this.onRetry,
    this.showProgress = true,
  });

  final String statusMessage;
  final String detail;
  final IconData icon;
  final int loadingProgress;
  final bool isLoading;
  final bool hasError;
  final String progressSemanticsLabel;
  final VoidCallback? onRetry;
  final bool showProgress;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final progressPercent = loadingProgress.clamp(0, 100);
    final progress = progressPercent / 100;
    final foregroundColor = colorScheme.onSurfaceVariant;
    final iconBackground = hasError
        ? colorScheme.errorContainer
        : colorScheme.primaryContainer;
    final iconColor = hasError
        ? colorScheme.onErrorContainer
        : colorScheme.onPrimaryContainer;

    return Card(
      elevation: 2,
      margin: const EdgeInsets.fromLTRB(12, 8, 12, 8),
      color: hasError
          ? Color.alphaBlend(
              colorScheme.errorContainer.withValues(alpha: 0.18),
              colorScheme.surface,
            )
          : null,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(
          color: hasError
              ? colorScheme.error.withValues(alpha: 0.35)
              : colorScheme.outlineVariant.withValues(alpha: 0.5),
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: iconBackground,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    hasError ? Icons.error_outline : icon,
                    color: iconColor,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        statusMessage,
                        style: theme.textTheme.titleSmall?.copyWith(
                          color: hasError ? colorScheme.onSurface : null,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        detail,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: foregroundColor,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                if (hasError && onRetry != null)
                  IconButtonM3E(
                    tooltip: '再試行',
                    icon: const Icon(Icons.refresh),
                    onPressed: onRetry,
                  )
                else if (!hasError && showProgress)
                  Text(
                    '$progressPercent%',
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: foregroundColor,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
              ],
            ),
            if (!hasError && isLoading && showProgress) ...[
              const SizedBox(height: 12),
              Semantics(
                label: progressSemanticsLabel,
                value: '$progressPercent%',
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(999),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 6,
                    backgroundColor: colorScheme.surfaceContainerHighest,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
