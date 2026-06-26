import 'package:flutter/material.dart';
import 'package:m3e_collection/m3e_collection.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class AtCoderClansScreen extends StatefulWidget {
  const AtCoderClansScreen({super.key});

  @override
  State<AtCoderClansScreen> createState() => _AtCoderClansScreenState();
}

class _AtCoderClansScreenState extends State<AtCoderClansScreen> {
  late final WebViewController _controller;
  bool _isLoading = true;
  bool _hasError = false;
  int _loadingProgress = 0;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (progress) {
            if (mounted) {
              setState(() {
                _loadingProgress = progress;
              });
            }
          },
          onPageStarted: (String url) {
            if (mounted) {
              setState(() {
                _isLoading = true;
                _hasError = false;
              });
            }
          },
          onPageFinished: (String url) {
            if (mounted) {
              setState(() {
                _isLoading = false;
                _loadingProgress = 100;
              });
            }
          },
          onWebResourceError: (WebResourceError error) {
            if (mounted) {
              setState(() {
                _isLoading = false;
                _hasError = true;
              });
            }
          },
          onNavigationRequest: (NavigationRequest request) async {
            final uri = Uri.parse(request.url);
            // kato-hiro.github.io 以外は外部ブラウザで開く
            if (uri.authority != 'kato-hiro.github.io') {
              if (await canLaunchUrl(uri)) {
                await launchUrl(uri, mode: LaunchMode.externalApplication);
              }
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse('https://kato-hiro.github.io/AtCoderClans/'));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarM3E(
        title: const Text('AtCoder Clans'),
        actions: [
          IconButtonM3E(
            tooltip: '再読み込み',
            icon: const Icon(Icons.refresh),
            onPressed: () {
              _controller.reload();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          _buildStatusHeader(context),
          Expanded(
            child: Stack(
              children: [
                WebViewWidget(controller: _controller),
                if (_hasError)
                  _buildStateOverlay(
                    context,
                    icon: Icons.error_outline,
                    title: 'AtCoder Clansを読み込めませんでした',
                    message: '通信状況を確認して再試行してください。',
                    isError: true,
                    action: SizedBox(
                      width: double.infinity,
                      child: ButtonM3E(
                        style: ButtonM3EStyle.filled,
                        icon: const Icon(Icons.refresh),
                        label: const Text('再試行'),
                        onPressed: () {
                          setState(() {
                            _isLoading = true;
                            _hasError = false;
                          });
                          _controller.reload();
                        },
                      ),
                    ),
                  )
                else if (_isLoading)
                  _buildStateOverlay(
                    context,
                    icon: Icons.travel_explore,
                    title: 'AtCoder Clansを読み込み中',
                    message: 'コンテスト情報や関連リンクを準備しています。',
                    action: const Center(child: LoadingIndicatorM3E()),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusHeader(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final progress = (_loadingProgress / 100).clamp(0.0, 1.0);
    final foregroundColor = _hasError
        ? colorScheme.onErrorContainer
        : colorScheme.onSurfaceVariant;
    final iconBackground = _hasError
        ? colorScheme.errorContainer
        : colorScheme.primaryContainer;
    final iconColor = _hasError
        ? colorScheme.onErrorContainer
        : colorScheme.onPrimaryContainer;

    return Card(
      elevation: 2,
      margin: const EdgeInsets.fromLTRB(12, 8, 12, 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    _hasError ? Icons.error_outline : Icons.travel_explore,
                    color: iconColor,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _hasError
                            ? '読み込みに失敗しました'
                            : _isLoading
                            ? 'ページを読み込んでいます'
                            : 'AtCoder Clans',
                        style: theme.textTheme.titleSmall?.copyWith(
                          color: _hasError ? foregroundColor : null,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '外部リンクはブラウザで開きます',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: foregroundColor,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  '$_loadingProgress%',
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: foregroundColor,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            if (!_hasError && _isLoading) ...[
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(999),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 6,
                  backgroundColor: colorScheme.surfaceContainerHighest,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStateOverlay(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String message,
    bool isError = false,
    Widget? action,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final foregroundColor = isError
        ? colorScheme.onErrorContainer
        : colorScheme.onSurfaceVariant;
    final iconBackground = isError
        ? colorScheme.errorContainer
        : colorScheme.primaryContainer;
    final iconColor = isError
        ? colorScheme.onErrorContainer
        : colorScheme.onPrimaryContainer;

    return Container(
      color: colorScheme.surface.withValues(alpha: 0.45),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Card(
            elevation: 3,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            clipBehavior: Clip.antiAlias,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: iconBackground,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(icon, color: iconColor),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              title,
                              style: theme.textTheme.titleMedium?.copyWith(
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
                  if (action != null) ...[const SizedBox(height: 16), action],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
