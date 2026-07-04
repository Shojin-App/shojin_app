import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:m3e_collection/m3e_collection.dart';

import '../../utils/text_style_helper.dart';

class CopyableCodeSection extends StatelessWidget {
  const CopyableCodeSection({
    super.key,
    required this.title,
    required this.content,
    required this.codeFontFamily,
    this.isError = false,
  });

  final String title;
  final String content;
  final String codeFontFamily;
  final bool isError;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: isError ? colorScheme.onErrorContainer : null,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              IconButtonM3E(
                tooltip: '$titleをコピー',
                icon: const Icon(Icons.copy_outlined, size: 18),
                onPressed: () async {
                  await Clipboard.setData(ClipboardData(text: content));
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text('$titleをコピーしました')));
                },
              ),
            ],
          ),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.all(8),
            width: double.infinity,
            constraints: const BoxConstraints(maxHeight: 150),
            decoration: BoxDecoration(
              color: isError
                  ? colorScheme.errorContainer.withValues(alpha: 0.55)
                  : colorScheme.surfaceContainerHighest.withValues(alpha: 0.45),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isError
                    ? colorScheme.error.withValues(alpha: 0.25)
                    : colorScheme.outlineVariant.withValues(alpha: 0.7),
              ),
            ),
            child: SingleChildScrollView(
              child: SelectableText(
                content.isEmpty ? '(空)' : content,
                style: getMonospaceTextStyle(
                  codeFontFamily,
                  fontSize: 13,
                  color: isError ? colorScheme.onErrorContainer : null,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
