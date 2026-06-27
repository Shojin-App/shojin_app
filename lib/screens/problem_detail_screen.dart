import 'dart:developer' as developer;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:m3e_collection/m3e_collection.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/problem.dart';
import '../providers/theme_provider.dart';
import '../services/atcoder_service.dart';
import '../utils/responsive_layout.dart';
import '../utils/text_style_helper.dart';
import '../widgets/tex_widget.dart';
import '../widgets/shared/app_loading_indicator.dart';

class ProblemDetailScreen extends StatefulWidget {
  final String? initialUrl; // Keep for potential direct URL loading
  final String?
  problemIdToLoad; // New: ID passed from MainScreen via ProblemsScreen
  final Function(String) onProblemChanged;

  const ProblemDetailScreen({
    super.key,
    this.initialUrl,
    this.problemIdToLoad, // Add to constructor
    required this.onProblemChanged,
  });

  @override
  State<ProblemDetailScreen> createState() => _ProblemDetailScreenState();
}

class _ProblemDetailScreenState extends State<ProblemDetailScreen> {
  final _urlController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final _atCoderService = AtCoderService();

  Problem? _problem;
  bool _isLoading = false;
  bool _isFetchPanelExpanded = false;
  String? _errorMessage;
  String? _lastLoadedProblemId; // Track the last ID loaded via problemIdToLoad

  @override
  void initState() {
    super.initState();
    developer.log(
      'ProblemDetailScreen initState: initialUrl=${widget.initialUrl}, problemIdToLoad=${widget.problemIdToLoad}',
      name: 'ProblemDetailScreen',
    );
    if (widget.problemIdToLoad != null &&
        widget.problemIdToLoad != 'default_problem') {
      _loadProblemFromId(widget.problemIdToLoad!);
    } else if (widget.initialUrl != null) {
      _urlController.text = widget.initialUrl!;
      _fetchProblem(); // Fetch based on initial URL
    }
  }

  @override
  void didUpdateWidget(ProblemDetailScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    developer.log(
      'ProblemDetailScreen didUpdateWidget: new problemIdToLoad=${widget.problemIdToLoad}, old problemIdToLoad=${oldWidget.problemIdToLoad}, lastLoaded=$_lastLoadedProblemId',
      name: 'ProblemDetailScreen',
    );
    // Check if problemIdToLoad changed, is not null, not default, and different from the last one loaded this way
    if (widget.problemIdToLoad != null &&
        widget.problemIdToLoad != 'default_problem' &&
        widget.problemIdToLoad != _lastLoadedProblemId) {
      developer.log(
        'Triggering load from problemIdToLoad: ${widget.problemIdToLoad}',
        name: 'ProblemDetailScreen',
      );
      _loadProblemFromId(widget.problemIdToLoad!);
    }
  }

  // New method to construct URL and fetch based on problemId
  void _loadProblemFromId(String problemId) {
    // Construct the URL (e.g., abc388_a -> https://atcoder.jp/contests/abc388/tasks/abc388_a)
    final parts = problemId.split('_');
    if (parts.length < 2) {
      developer.log(
        'Invalid problemId format: $problemId',
        name: 'ProblemDetailScreen',
      );
      setState(() {
        _errorMessage = '無効な問題ID形式です: $problemId';
      });
      return;
    }
    // Heuristic: Assume the part before the last underscore is the contest ID
    // This might fail for IDs like 'arc100_a_example'. Needs robust parsing if IDs vary.
    // Let's assume standard format like 'abcXXX_Y' or 'arcXXX_Y'
    final contestId =
        parts.first; // Simpler assumption: first part is contest ID
    final taskId = problemId; // The full ID is the task ID in the URL
    final url = 'https://atcoder.jp/contests/$contestId/tasks/$taskId';

    developer.log(
      'Constructed URL from ID $problemId: $url',
      name: 'ProblemDetailScreen',
    );

    // Update the text field and trigger fetch
    _urlController.text = url;
    _lastLoadedProblemId = problemId; // Mark this ID as being loaded
    _fetchProblem(); // Fetch using the updated URL in the controller
  }

  @override
  void dispose() {
    _urlController.dispose();
    super.dispose();
  }

  Future<void> _fetchProblem() async {
    // Validate using the controller's text, which is now set correctly
    // Use a temporary form key or validate directly if needed without relying on user interaction
    // For automatic fetch, let's bypass the form validation for simplicity,
    // assuming the constructed URL is valid. Add validation if needed.
    // if (!_formKey.currentState!.validate()) return; // Skip form validation for automatic fetch

    final urlToFetch = _urlController.text;
    if (!_atCoderService.isValidAtCoderUrl(urlToFetch)) {
      developer.log(
        'Invalid URL constructed or entered: $urlToFetch',
        name: 'ProblemDetailScreen',
      );
      setState(() {
        _errorMessage = '無効なAtCoder URLです: $urlToFetch';
        _isLoading = false; // Ensure loading indicator stops
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      // Clear previous problem when starting fetch? Optional.
      // _problem = null;
    });

    developer.log(
      'Fetching problem from URL: $urlToFetch',
      name: 'ProblemDetailScreen',
    );

    try {
      final problem = await _atCoderService.fetchProblem(urlToFetch);
      setState(() {
        _problem = problem;
        _isLoading = false;
        _isFetchPanelExpanded = false;
        // Reset last loaded ID if fetch fails? Or keep it?
      });
      // Problem fetched successfully, call the callback to update EditorScreen
      if (_problem != null) {
        developer.log(
          'Problem fetched successfully: ${_problem!.url}',
          name: 'ProblemDetailScreen',
        );
        // Pass the *original URL* that was successfully fetched back up
        widget.onProblemChanged(_problem!.url);
      }
    } catch (e) {
      developer.log(
        'Failed to fetch problem: $e',
        name: 'ProblemDetailScreen',
        error: e,
      );
      setState(() {
        _errorMessage =
            '問題の取得に失敗しました: $e\nURL: $urlToFetch'; // Include URL in error
        _isLoading = false;
        // Reset last loaded ID on failure so retry is possible?
        // _lastLoadedProblemId = null;
      });
    }
  }

  Future<void> _pasteUrlFromClipboard() async {
    final data = await Clipboard.getData(Clipboard.kTextPlain);
    final text = data?.text?.trim();
    if (!mounted) return;
    if (text == null || text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('クリップボードにURLがありません')));
      return;
    }
    _urlController.text = text;
    setState(() {
      _errorMessage = null;
    });
  }

  void _clearUrl() {
    _urlController.clear();
    setState(() {
      _problem = null;
      _errorMessage = null;
      _lastLoadedProblemId = null;
      _isFetchPanelExpanded = true;
    });
  }

  void _copyErrorMessage() {
    if (_errorMessage == null) return;
    Clipboard.setData(ClipboardData(text: _errorMessage!));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('エラーメッセージをコピーしました'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  Widget _buildFetchPanel(BuildContext context) {
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
                    Icons.article_outlined,
                    color: colorScheme.onPrimaryContainer,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '問題を取得',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'AtCoderの問題URLを貼り付けて本文とサンプルを表示',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Form(
              key: _formKey,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final inputBorder = OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: colorScheme.outlineVariant),
                  );
                  final urlField = TextFormField(
                    controller: _urlController,
                    decoration: InputDecoration(
                      labelText: 'AtCoder 問題URL',
                      hintText:
                          'https://atcoder.jp/contests/abc000/tasks/abc000_a',
                      filled: true,
                      fillColor: colorScheme.surfaceContainerHighest.withValues(
                        alpha: 0.35,
                      ),
                      border: inputBorder,
                      enabledBorder: inputBorder,
                      focusedBorder: inputBorder.copyWith(
                        borderSide: BorderSide(
                          color: colorScheme.primary,
                          width: 1.6,
                        ),
                      ),
                      errorBorder: inputBorder.copyWith(
                        borderSide: BorderSide(color: colorScheme.error),
                      ),
                      focusedErrorBorder: inputBorder.copyWith(
                        borderSide: BorderSide(
                          color: colorScheme.error,
                          width: 1.6,
                        ),
                      ),
                      prefixIcon: IconButton(
                        tooltip: 'クリップボードから貼り付け',
                        icon: const Icon(Icons.content_paste),
                        onPressed: _pasteUrlFromClipboard,
                      ),
                      suffixIcon: IconButton(
                        tooltip: 'URLをクリア',
                        icon: const Icon(Icons.clear),
                        onPressed: _urlController.text.isEmpty
                            ? null
                            : _clearUrl,
                      ),
                    ),
                    onChanged: (_) => setState(() {}),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'URLを入力してください';
                      }
                      if (!_atCoderService.isValidAtCoderUrl(value)) {
                        return '正しいAtCoderの問題URLを入力してください';
                      }
                      return null;
                    },
                  );
                  final fetchButton = ButtonM3E(
                    style: ButtonM3EStyle.filled,
                    onPressed: _isLoading
                        ? null
                        : () {
                            if (_formKey.currentState!.validate()) {
                              _lastLoadedProblemId = null;
                              _fetchProblem();
                            }
                          },
                    icon: _isLoading
                        ? SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation(
                                colorScheme.onPrimary,
                              ),
                            ),
                          )
                        : const Icon(Icons.download_outlined),
                    label: const Text('取得'),
                  );

                  if (constraints.maxWidth < 560) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        urlField,
                        const SizedBox(height: 12),
                        fetchButton,
                      ],
                    );
                  }

                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: urlField),
                      const SizedBox(width: 12),
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: fetchButton,
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessagePanel(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String message,
    bool isError = false,
    VoidCallback? onCopy,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final backgroundColor = isError
        ? colorScheme.errorContainer
        : colorScheme.surfaceContainerHighest.withValues(alpha: 0.45);
    final foregroundColor = isError
        ? colorScheme.onErrorContainer
        : colorScheme.onSurfaceVariant;
    final iconBackground = isError
        ? colorScheme.error.withValues(alpha: 0.12)
        : colorScheme.primaryContainer;
    final iconColor = isError
        ? colorScheme.onErrorContainer
        : colorScheme.onPrimaryContainer;

    return Card(
      elevation: 2,
      color: backgroundColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: isError
              ? colorScheme.error.withValues(alpha: 0.24)
              : colorScheme.outlineVariant.withValues(alpha: 0.7),
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: iconBackground,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(child: Icon(icon, color: iconColor)),
            ),
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
                  SelectableText(
                    message,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: foregroundColor,
                    ),
                  ),
                ],
              ),
            ),
            if (onCopy != null) ...[
              const SizedBox(width: 8),
              IconButtonM3E(
                icon: Icon(Icons.copy, color: foregroundColor),
                tooltip: 'コピー',
                onPressed: onCopy,
              ),
            ],
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final horizontalPadding = ResponsiveLayout.horizontalPadding(context);

    return Scaffold(
      appBar: AppBarM3E(
        title: const Text('問題詳細'),
        actions: [
          if (_problem != null)
            IconButtonM3E(
              tooltip: _isFetchPanelExpanded ? 'URL入力を閉じる' : '別の問題を開く',
              icon: Icon(_isFetchPanelExpanded ? Icons.close : Icons.add_link),
              onPressed: () {
                setState(() {
                  _isFetchPanelExpanded = !_isFetchPanelExpanded;
                });
              },
            ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            horizontalPadding,
            16,
            horizontalPadding,
            16,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (_problem == null ||
                  _isFetchPanelExpanded ||
                  _errorMessage != null)
                _buildFetchPanel(context),
              if (_errorMessage != null)
                Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: _buildMessagePanel(
                    context,
                    icon: Icons.error_outline,
                    title: 'エラーが発生しました',
                    message: 'URLが正しいことを確認し、もう一度お試しください。\n\n$_errorMessage',
                    isError: true,
                    onCopy: _copyErrorMessage,
                  ),
                ),
              const SizedBox(height: 12),
              Expanded(
                child: _isLoading
                    ? const Center(
                        child: AppLoadingIndicator(semanticsLabel: '問題を読み込み中'),
                      )
                    : (_problem != null
                          ? _buildProblemView(_problem!)
                          : Center(
                              child: _buildMessagePanel(
                                context,
                                icon: Icons.link_outlined,
                                title: '問題がまだ選択されていません',
                                message:
                                    '問題URLを入力するか、ブラウザやおすすめ問題から問題を選択してください。',
                              ),
                            )),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProblemView(Problem problem) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final codeFontFamily = themeProvider.codeFontFamily;
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return SingleChildScrollView(
      padding: EdgeInsets.only(bottom: bottomPadding > 0 ? bottomPadding : 16),
      child: Padding(
        padding: const EdgeInsets.only(top: 16),
        child: Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          clipBehavior: Clip.antiAlias,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
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
                        Icons.assignment_outlined,
                        color: colorScheme.onSecondaryContainer,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (problem.contestName.isNotEmpty &&
                              problem.contestName != 'コンテスト名が見つかりません') ...[
                            Text(
                              problem.contestName,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                          ],
                          TexWidget(
                            content: problem.title,
                            textStyle: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButtonM3E(
                      icon: const Icon(Icons.open_in_new),
                      tooltip: '元ページを開く',
                      onPressed: () => launchUrl(
                        Uri.parse(problem.url),
                        mode: LaunchMode.externalApplication,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Divider(color: colorScheme.outlineVariant),
                _buildSection('問題文', problem.statement, codeFontFamily),
                _buildSection('制約', problem.constraints, codeFontFamily),
                _buildSection('入力', problem.inputFormat, codeFontFamily),
                _buildSection('出力', problem.outputFormat, codeFontFamily),
                ...problem.samples.map(
                  (sample) => _buildSampleIO(sample, codeFontFamily),
                ),
                const SizedBox(height: 16),
                Divider(color: colorScheme.outlineVariant),
                Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      size: 16,
                      color: colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '出典: AtCoder',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSection(String title, String content, String codeFontFamily) {
    if (content.isEmpty) return const SizedBox.shrink();

    developer.log('セクション[$title]の内容: $content');
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    List<Widget> contentWidgets = [];
    final parts = content.split(RegExp(r'```'));

    // 「入力」セクションで、かつコードブロックがない場合の特別処理
    if (title == '入力' && parts.length <= 1) {
      contentWidgets.add(
        Container(
          width: double.infinity,
          margin: const EdgeInsets.symmetric(vertical: 8),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.55),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: colorScheme.outlineVariant.withValues(alpha: 0.7),
            ),
          ),
          // TexWidgetを使い、フォントスタイルを維持
          child: TexWidget(
            content: content,
            textStyle: theme.textTheme.bodyMedium,
          ),
        ),
      );
    } else if (parts.length > 1) {
      // コードブロックが含まれている場合の通常の処理
      for (int i = 0; i < parts.length; i++) {
        if (parts[i].trim().isEmpty) continue;

        if (i % 2 == 0) {
          contentWidgets.add(
            TexWidget(
              content: parts[i].trim(),
              textStyle: theme.textTheme.bodyMedium,
            ),
          );
        } else {
          contentWidgets.add(
            Container(
              width: double.infinity,
              margin: const EdgeInsets.symmetric(vertical: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest.withValues(
                  alpha: 0.55,
                ),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: colorScheme.outlineVariant.withValues(alpha: 0.7),
                ),
              ),
              child: Text(
                parts[i].trim(),
                style: getMonospaceTextStyle(codeFontFamily),
              ),
            ),
          );
        }
      }
    } else {
      // 「入力」セクション以外でコードブロックがない場合の通常の処理
      contentWidgets.add(
        TexWidget(content: content, textStyle: theme.textTheme.bodyMedium),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: colorScheme.primaryContainer.withValues(alpha: 0.65),
            borderRadius: BorderRadius.circular(999),
          ),
          child: Text(
            title,
            style: theme.textTheme.titleSmall?.copyWith(
              color: colorScheme.onPrimaryContainer,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        const SizedBox(height: 8),
        ...contentWidgets,
      ],
    );
  }

  Widget _buildSampleIO(SampleIO sample, String codeFontFamily) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        _buildSampleBlock(
          title: '入力例 ${sample.index}',
          content: sample.input,
          codeFontFamily: codeFontFamily,
          theme: theme,
          colorScheme: colorScheme,
          copiedMessage: '入力例をコピーしました',
        ),
        const SizedBox(height: 8),
        _buildSampleBlock(
          title: '出力例 ${sample.index}',
          content: sample.output,
          codeFontFamily: codeFontFamily,
          theme: theme,
          colorScheme: colorScheme,
          copiedMessage: '出力例をコピーしました',
        ),
      ],
    );
  }

  Widget _buildSampleBlock({
    required String title,
    required String content,
    required String codeFontFamily,
    required ThemeData theme,
    required ColorScheme colorScheme,
    required String copiedMessage,
  }) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.7),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 8, 4),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                IconButtonM3E(
                  icon: const Icon(Icons.copy, size: 16),
                  tooltip: '$titleをコピー',
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: content));
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(SnackBar(content: Text(copiedMessage)));
                  },
                ),
              ],
            ),
          ),
          Divider(height: 1, color: colorScheme.outlineVariant),
          Padding(
            padding: const EdgeInsets.all(12),
            child: SelectableText(
              content,
              style: getMonospaceTextStyle(codeFontFamily),
            ),
          ),
        ],
      ),
    );
  }
}
