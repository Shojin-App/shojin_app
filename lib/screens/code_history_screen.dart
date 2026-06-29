import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:m3e_collection/m3e_collection.dart';
import 'package:intl/intl.dart';

import '../models/code_history.dart';
import '../services/code_history_service.dart';
import '../utils/responsive_layout.dart';
import '../widgets/shared/app_loading_indicator.dart';
import '../widgets/shared/app_state_card.dart';

class CodeHistoryScreen extends StatefulWidget {
  final String problemId;

  const CodeHistoryScreen({super.key, required this.problemId});

  @override
  State<CodeHistoryScreen> createState() => _CodeHistoryScreenState();
}

class _CodeHistoryScreenState extends State<CodeHistoryScreen> {
  final CodeHistoryService _codeHistoryService = CodeHistoryService();
  late Future<List<CodeHistory>> _historyFuture;

  String _formatTimestamp(DateTime timestamp) {
    return DateFormat('yyyy/MM/dd HH:mm:ss').format(timestamp.toLocal());
  }

  @override
  void initState() {
    super.initState();
    _historyFuture = _codeHistoryService.getHistory(widget.problemId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarM3E(title: const Text('コード履歴')),
      body: FutureBuilder<List<CodeHistory>>(
        future: _historyFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return _buildStateCard(
              context,
              icon: Icons.history,
              title: '履歴を読み込み中',
              message: '保存されたコード履歴を確認しています。',
              child: const Padding(
                padding: EdgeInsets.only(top: 16),
                child: AppLoadingIndicator(semanticsLabel: 'コード履歴を読み込み中'),
              ),
            );
          } else if (snapshot.hasError) {
            return _buildStateCard(
              context,
              icon: Icons.error_outline,
              title: '履歴を読み込めませんでした',
              message: snapshot.error.toString(),
              isError: true,
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return _buildStateCard(
              context,
              icon: Icons.history_toggle_off,
              title: '履歴はまだありません',
              message: 'コードを編集すると、この問題の履歴が自動で保存されます。',
            );
          } else {
            final historyList = snapshot.data!;
            return ListView.builder(
              padding: ResponsiveLayout.listPadding(context),
              itemCount: historyList.length,
              itemBuilder: (context, index) {
                final history = historyList[index];
                return _buildHistoryCard(context, history);
              },
            );
          }
        },
      ),
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
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16),
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

  Widget _buildHistoryCard(BuildContext context, CodeHistory history) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final borderRadius = BorderRadius.circular(8);
    final lineCount = history.content.isEmpty
        ? 0
        : '\n'.allMatches(history.content).length + 1;

    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: borderRadius),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        borderRadius: borderRadius,
        onTap: () => _showHistoryDetailDialog(history),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: colorScheme.secondaryContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.restore,
                  color: colorScheme.onSecondaryContainer,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _formatTimestamp(history.timestamp),
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$lineCount行のコード',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: colorScheme.surfaceContainerHighest.withValues(
                          alpha: 0.45,
                        ),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: colorScheme.outlineVariant.withValues(
                            alpha: 0.7,
                          ),
                        ),
                      ),
                      child: Text(
                        history.content,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontFamily: 'monospace',
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Icon(Icons.chevron_right, color: colorScheme.onSurfaceVariant),
            ],
          ),
        ),
      ),
    );
  }

  void _showHistoryDetailDialog(CodeHistory history) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(Icons.history, color: colorScheme.onPrimaryContainer),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                _formatTimestamp(history.timestamp),
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
        content: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: colorScheme.secondaryContainer.withValues(alpha: 0.55),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.restore,
                      size: 18,
                      color: colorScheme.onSecondaryContainer,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'この内容をエディタに復元できます。',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSecondaryContainer,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Flexible(
                child: SingleChildScrollView(
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceContainerHighest.withValues(
                        alpha: 0.45,
                      ),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: colorScheme.outlineVariant.withValues(
                          alpha: 0.7,
                        ),
                      ),
                    ),
                    child: SelectableText(
                      history.content,
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontFamily: 'monospace',
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        actions: [
          ButtonM3E(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.close),
            label: const Text('キャンセル'),
            style: ButtonM3EStyle.text,
          ),
          ButtonM3E(
            onPressed: () async {
              await Clipboard.setData(ClipboardData(text: history.content));
              if (!context.mounted) return;
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text('コードをコピーしました')));
            },
            icon: const Icon(Icons.copy_outlined),
            label: const Text('コピー'),
            style: ButtonM3EStyle.text,
          ),
          ButtonM3E(
            onPressed: () {
              Navigator.of(context).pop(); // Close the dialog
              Navigator.of(
                context,
              ).pop(history.content); // Pop the screen and return the code
            },
            icon: const Icon(Icons.restore),
            label: const Text('復元'),
            style: ButtonM3EStyle.filled,
          ),
        ],
      ),
    );
  }
}
