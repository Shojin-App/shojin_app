import 'package:flutter/material.dart';
import 'package:m3e_collection/m3e_collection.dart';

import '../widgets/tex_widget.dart';

class TexTestScreen extends StatelessWidget {
  const TexTestScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarM3E(title: const Text('TeX表示テスト')),
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildIntroCard(context),
              const SizedBox(height: 12),
              _buildTestSection(
                context,
                'インライン数式',
                'この式 \$x = a + b\$ は足し算を表します。また、\$y \\leq 10\$ という制約があります。',
                Icons.text_fields,
              ),
              _buildTestSection(
                context,
                'ディスプレイ数式',
                'この問題の解は次の式で表されます：\n\$\$x = \\frac{-b \\pm \\sqrt{b^2-4ac}}{2a}\$\$',
                Icons.functions,
              ),
              _buildTestSection(
                context,
                '複数の数式',
                'まず \$n \\leq 10^5\$ とします。次に、総和は \$\\sum_{i=1}^{n} a_i\$ です。',
                Icons.view_list_outlined,
              ),
              _buildTestSection(
                context,
                'AtCoder風の制約',
                '制約：\n• \$1 \\leq N \\leq 2 \\times 10^5\$\n• \$1 \\leq A_i \\leq 10^9\$\n• \$\\sum A_i \\leq 10^{18}\$',
                Icons.rule_outlined,
              ),
              _buildTestSection(
                context,
                'ギリシャ文字',
                '角度 \$\\theta\$ は \$0 \\leq \\theta \\leq \\pi\$ を満たします。また、\$\\alpha + \\beta = \\gamma\$ です。',
                Icons.language,
              ),
              _buildTestSection(
                context,
                '基本的なTeXコマンド',
                'a \\leq b, c \\geq d, e \\times f, g \\div h, \\pm 1, a \\neq b, x \\in S, A \\subset B',
                Icons.short_text,
              ),
              _buildTestSection(
                context,
                'コードブロック付き',
                '入力は以下の形式で与えられる：\n\n```\nN\nA_1 A_2 ... A_N\n```\n\nここで、\$1 \\leq N \\leq 10^5\$ です。',
                Icons.code,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIntroCard(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.functions,
                color: colorScheme.onPrimaryContainer,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'TeXレンダリング確認',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '問題文で使う数式やコードブロックの表示を確認します。',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTestSection(
    BuildContext context,
    String title,
    String content,
    IconData icon,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
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
                  child: Center(
                    child: Icon(icon, color: colorScheme.onSecondaryContainer),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest.withValues(
                  alpha: 0.35,
                ),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: colorScheme.outlineVariant.withValues(alpha: 0.7),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.visibility_outlined,
                        size: 16,
                        color: colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'プレビュー',
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  TexWidget(content: content),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
