import 'package:flutter/material.dart';
import 'package:m3e_collection/m3e_collection.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import '../widgets/shared/app_loading_indicator.dart';
import '../widgets/shared/app_state_card.dart';
import '../widgets/shared/responsive_action.dart';
import '../widgets/shared/web_content_status_header.dart';
import '../utils/platform_support.dart';

class AtCoderClansScreen extends StatefulWidget {
  const AtCoderClansScreen({super.key});

  @override
  State<AtCoderClansScreen> createState() => _AtCoderClansScreenState();
}

class _AtCoderClansScreenState extends State<AtCoderClansScreen> {
  static final _clansUri = Uri.parse(
    'https://kato-hiro.github.io/AtCoderClans/',
  );

  WebViewController? _controller;
  bool _isLoading = true;
  bool _hasError = false;
  bool _embeddedBrowserUnavailable = false;
  int _loadingProgress = 0;

  @override
  void initState() {
    super.initState();
    if (!supportsEmbeddedWebView) {
      _embeddedBrowserUnavailable = true;
      _isLoading = false;
      return;
    }

    try {
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
        ..loadRequest(_clansUri);
    } catch (_) {
      // 対応対象でも実装が利用できない場合は、永久ローディングではなく
      // 外部ブラウザへ退避できる状態にする。
      _embeddedBrowserUnavailable = true;
      _isLoading = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarM3E(
        title: const Text('AtCoder Clans'),
        actions: [
          IconButtonM3E(
            tooltip: _embeddedBrowserUnavailable ? '外部ブラウザで開く' : '再読み込み',
            icon: Icon(
              _embeddedBrowserUnavailable ? Icons.open_in_new : Icons.refresh,
            ),
            onPressed: _embeddedBrowserUnavailable ? _openExternally : _reload,
          ),
        ],
      ),
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            WebContentStatusHeader(
              statusMessage: _embeddedBrowserUnavailable
                  ? '外部ブラウザで開きます'
                  : _hasError
                  ? '読み込みに失敗しました'
                  : _isLoading
                  ? 'ページを読み込んでいます'
                  : 'AtCoder Clans',
              detail: _embeddedBrowserUnavailable
                  ? '埋め込み表示に対応していない環境です'
                  : '外部リンクはブラウザで開きます',
              icon: Icons.travel_explore,
              loadingProgress: _loadingProgress,
              isLoading: !_embeddedBrowserUnavailable && _isLoading,
              hasError: _hasError,
              progressSemanticsLabel: 'AtCoder Clansの読み込み進捗',
              onRetry: _embeddedBrowserUnavailable ? _openExternally : _reload,
              showProgress: !_embeddedBrowserUnavailable,
            ),
            Expanded(
              child: Stack(
                children: [
                  if (_embeddedBrowserUnavailable)
                    _buildStateOverlay(
                      context,
                      icon: Icons.open_in_browser,
                      title: '埋め込み表示に対応していません',
                      message: 'この環境では、AtCoder Clansを外部ブラウザで開きます。',
                      action: ResponsiveAction(
                        child: ButtonM3E(
                          style: ButtonM3EStyle.filled,
                          icon: const Icon(Icons.open_in_new),
                          label: const Text('外部で開く'),
                          onPressed: _openExternally,
                        ),
                      ),
                    )
                  else ...[
                    WebViewWidget(controller: _controller!),
                    if (_hasError)
                      _buildStateOverlay(
                        context,
                        icon: Icons.error_outline,
                        title: 'AtCoder Clansを読み込めませんでした',
                        message: '通信状況を確認して再試行してください。',
                        isError: true,
                        action: ResponsiveAction(
                          child: ButtonM3E(
                            style: ButtonM3EStyle.filled,
                            icon: const Icon(Icons.refresh),
                            label: const Text('再試行'),
                            onPressed: _reload,
                          ),
                        ),
                      )
                    else if (_isLoading)
                      _buildStateOverlay(
                        context,
                        icon: Icons.travel_explore,
                        title: 'AtCoder Clansを読み込み中',
                        message: 'コンテスト情報や関連リンクを準備しています。',
                        action: const Center(
                          child: AppLoadingIndicator(
                            semanticsLabel: 'AtCoder Clansを読み込み中',
                          ),
                        ),
                      ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _reload() {
    setState(() {
      _loadingProgress = 0;
      _isLoading = true;
      _hasError = false;
    });
    _controller?.reload();
  }

  Future<void> _openExternally() async {
    var launched = false;
    try {
      launched = await launchUrl(
        _clansUri,
        mode: LaunchMode.externalApplication,
      );
    } catch (_) {
      // launchUrl may throw when no external handler is registered.
    }
    if (!launched && mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('AtCoder Clansを開けませんでした')));
    }
  }

  Widget _buildStateOverlay(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String message,
    bool isError = false,
    Widget? action,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      color: colorScheme.surface.withValues(alpha: 0.45),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 640),
            child: AppStateCard(
              margin: EdgeInsets.zero,
              icon: icon,
              title: title,
              message: message,
              isError: isError,
              child: action == null
                  ? null
                  : Padding(
                      padding: const EdgeInsets.only(top: 16),
                      child: action,
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
