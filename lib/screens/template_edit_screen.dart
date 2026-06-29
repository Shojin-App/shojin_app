import 'package:flutter/material.dart';
import 'package:m3e_collection/m3e_collection.dart';
import 'package:provider/provider.dart';

import '../providers/template_provider.dart';
import '../utils/text_style_helper.dart';
import '../widgets/programming_language_icon.dart';

class TemplateEditScreen extends StatefulWidget {
  final String language;

  const TemplateEditScreen({super.key, required this.language});

  @override
  State<TemplateEditScreen> createState() => _TemplateEditScreenState();
}

class _TemplateEditScreenState extends State<TemplateEditScreen> {
  late TextEditingController _controller;
  bool _isEdited = false;
  late TemplateProvider _templateProvider;

  @override
  void initState() {
    super.initState();
    _templateProvider = Provider.of<TemplateProvider>(context, listen: false);
    // 現在のテンプレート（カスタムまたはデフォルト）を取得
    String currentTemplate = _templateProvider.getTemplate(widget.language);
    _controller = TextEditingController(text: currentTemplate);

    // テキスト変更を監視
    _controller.addListener(() {
      setState(() {
        _isEdited = true;
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // テンプレートを保存する
  void _saveTemplate() {
    _templateProvider.setTemplate(widget.language, _controller.text);
    setState(() {
      _isEdited = false;
    });
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('${widget.language}のテンプレートを保存しました')));
  }

  // テンプレートをリセットする
  void _resetTemplate() {
    showDialog(
      context: context,
      builder: (context) {
        final theme = Theme.of(context);
        final colorScheme = theme.colorScheme;

        return AlertDialog(
          title: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: colorScheme.tertiaryContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.restart_alt,
                  color: colorScheme.onTertiaryContainer,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'テンプレートをリセット',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          content: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: colorScheme.tertiaryContainer.withValues(alpha: 0.55),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '${widget.language}のテンプレートをデフォルトに戻しますか？',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onTertiaryContainer,
              ),
            ),
          ),
          actions: [
            ButtonM3E(
              style: ButtonM3EStyle.text,
              onPressed: () => Navigator.of(context).pop(),
              label: const Text('キャンセル'),
            ),
            ButtonM3E(
              style: ButtonM3EStyle.text,
              onPressed: () {
                _controller.text = _templateProvider.getDefaultTemplate(
                  widget.language,
                );
                _templateProvider.resetTemplate(widget.language);
                Navigator.of(context).pop();
                setState(() {
                  _isEdited = false;
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('${widget.language}のテンプレートをリセットしました')),
                );
              },
              icon: const Icon(Icons.restart_alt),
              label: const Text('リセット'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarM3E(
        title: Text(
          '${widget.language}のテンプレート編集',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        actions: [
          IconButtonM3E(
            onPressed: _resetTemplate,
            icon: const Icon(Icons.refresh),
            tooltip: 'デフォルトに戻す',
            semanticLabel: 'デフォルトに戻す',
          ),
          IconButtonM3E(
            onPressed: _isEdited ? _saveTemplate : null,
            icon: const Icon(Icons.save_outlined),
            tooltip: '保存',
            semanticLabel: '保存',
          ),
        ],
      ),
      body: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildTemplateHeader(context),
              const SizedBox(height: 12),
              Expanded(child: _buildEditorCard(context)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTemplateHeader(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final statusColor = _isEdited
        ? colorScheme.tertiary
        : colorScheme.onSurfaceVariant;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      clipBehavior: Clip.antiAlias,
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
              child: Center(
                child: ProgrammingLanguageIcon(
                  language: widget.language,
                  size: 26,
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.language,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _isEdited ? '未保存の変更があります' : '保存済みのテンプレート',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: statusColor,
                      fontWeight: _isEdited ? FontWeight.w700 : null,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: _isEdited
                    ? colorScheme.tertiaryContainer
                    : colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                _isEdited ? '編集中' : '保存済み',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: _isEdited
                      ? colorScheme.onTertiaryContainer
                      : colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEditorCard(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
            child: Row(
              children: [
                Icon(Icons.code, size: 20, color: colorScheme.onSurfaceVariant),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '初期コード',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                Text(
                  '${_controller.text.length}文字',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          Divider(height: 1, color: colorScheme.outlineVariant),
          Expanded(
            child: Container(
              color: colorScheme.surfaceContainerHighest.withValues(
                alpha: 0.35,
              ),
              child: TextField(
                controller: _controller,
                maxLines: null,
                expands: true,
                style: getMonospaceTextStyle('monospace', fontSize: 14),
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.all(14.0),
                  border: InputBorder.none,
                  hintText: '// テンプレートを編集',
                  hintStyle: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    fontFamily: 'monospace',
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
