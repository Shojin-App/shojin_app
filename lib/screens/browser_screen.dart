import 'dart:developer' as developer;

import 'package:flutter/material.dart';
import 'package:m3e_collection/m3e_collection.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../constants/browser_constants.dart';
import '../models/browser_site.dart';
import '../providers/theme_provider.dart';
import '../services/browser_site_service.dart';
import '../utils/platform_support.dart';
import '../widgets/browser_site_form_fields.dart';
import '../widgets/browser_site_switcher.dart';
import '../widgets/shared/app_loading_indicator.dart';
import '../widgets/shared/responsive_action.dart';

class BrowserScreen extends StatefulWidget {
  final Function(String) navigateToProblem;

  const BrowserScreen({super.key, required this.navigateToProblem});

  @override
  State<BrowserScreen> createState() => _BrowserScreenState();
}

class _BrowserScreenState extends State<BrowserScreen>
    with AutomaticKeepAliveClientMixin {
  late WebViewController _controller;
  final ScrollController _siteScrollController = ScrollController();
  List<BrowserSite> _sites = [];
  bool _isControllerReady = false;
  bool _loadFailed = false;
  String _currentUrl = '';
  bool _isLoadingWebView = false;
  bool _embeddedBrowserUnavailable = false;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  @override
  void dispose() {
    _siteScrollController.dispose();
    super.dispose();
  }

  Future<void> _initialize() async {
    try {
      _sites = await BrowserSiteService.loadSites();
      final prefs = await SharedPreferences.getInstance();
      final atcoderUsername = prefs.getString('atcoder_username');

      String initialUrl = BrowserConstants.defaultSites.first.url;
      if (initialUrl == BrowserConstants.defaultSites[1].url &&
          atcoderUsername != null &&
          atcoderUsername.isNotEmpty) {
        initialUrl = '${BrowserConstants.defaultSites[1].url}$atcoderUsername';
      }
      _currentUrl = initialUrl;

      // webview_flutterが実装を持たない環境では、コントローラー生成を試みると
      // 初期化Futureが失敗してローディング表示が残り続ける。
      if (!supportsEmbeddedWebView) {
        _embeddedBrowserUnavailable = true;
        if (mounted) setState(() {});
        _updateMissingMetadata();
        return;
      }

      _controller = WebViewController()
        ..setJavaScriptMode(JavaScriptMode.unrestricted)
        ..setBackgroundColor(const Color(0x00000000))
        ..setNavigationDelegate(
          NavigationDelegate(
            onPageStarted: (String url) {
              if (mounted) {
                setState(() {
                  _isLoadingWebView = true;
                  _loadFailed = false;
                });
              }
            },
            onPageFinished: (String url) {
              if (mounted) {
                setState(() {
                  _isLoadingWebView = false;
                  _loadFailed = false;
                });
              }
            },
            onWebResourceError: (WebResourceError error) {
              if (mounted) {
                setState(() {
                  _isLoadingWebView = false;
                  _loadFailed = true;
                });
              }
              developer.log(
                'WebView load error: ${error.description}',
                name: 'BrowserScreenWebView',
              );
            },
            onNavigationRequest: _handleNavigationRequest,
          ),
        )
        ..loadRequest(Uri.parse(initialUrl));

      _isControllerReady = true;
      if (mounted) setState(() {});
      _updateMissingMetadata();
    } catch (error, stackTrace) {
      // 対応プラットフォームでもWebView実装が利用できない場合は、永久に
      // 待たせず外部ブラウザへ退避できる状態を表示する。
      _embeddedBrowserUnavailable = true;
      developer.log(
        'Failed to initialize embedded browser',
        name: 'BrowserScreenWebView',
        error: error,
        stackTrace: stackTrace,
      );
      if (mounted) setState(() {});
    }
  }

  Future<void> _openSiteExternally(String url) async {
    try {
      final launched = await launchUrl(
        Uri.parse(url),
        mode: LaunchMode.externalApplication,
      );
      if (!launched && mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('サイトを開けませんでした')));
      }
    } catch (error) {
      developer.log(
        'Failed to open site externally: $url',
        name: 'BrowserScreenWebView',
        error: error,
      );
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('サイトを開けませんでした')));
      }
    }
  }

  NavigationDecision _handleNavigationRequest(NavigationRequest request) {
    _currentUrl = request.url;
    final uri = Uri.parse(request.url);
    developer.log(
      'Navigating to: ${request.url}',
      name: 'BrowserScreenWebView',
    );

    // 1. AtCoder problem page check
    if (uri.host == BrowserConstants.atcoderHost &&
        uri.pathSegments.length == BrowserConstants.atcoderProblemPathLength &&
        uri.pathSegments[BrowserConstants.atcoderContestIndex] ==
            BrowserConstants.atcoderProblemPathSegments[0] &&
        uri.pathSegments[BrowserConstants.atcoderTasksIndex] ==
            BrowserConstants.atcoderProblemPathSegments[1]) {
      if (uri.pathSegments[BrowserConstants.atcoderProblemIndex].contains(
        '_',
      )) {
        widget.navigateToProblem(
          uri.pathSegments[BrowserConstants.atcoderProblemIndex],
        );
        if (mounted) {
          setState(() {
            _isLoadingWebView = false;
          });
        }
        return NavigationDecision.prevent;
      }
    }

    // 2. Allowed site check (default sites + user-added)
    final requestBaseUrl = uri.origin;
    bool isAllowedSite = _isAllowedSite(requestBaseUrl, request.url);

    if (isAllowedSite) {
      developer.log(
        'Allowing navigation within allowed sites: ${request.url}',
        name: 'BrowserScreenWebView',
      );
      return NavigationDecision.navigate;
    }

    // 3. Allow navigation to non-allowed sites within WebView
    developer.log(
      'Allowing navigation to non-allowed site: ${request.url}',
      name: 'BrowserScreenWebView',
    );
    return NavigationDecision.navigate;
  }

  bool _isAllowedSite(String requestBaseUrl, String fullUrl) {
    // Check default sites
    for (final defaultSite in BrowserConstants.defaultSites) {
      if (fullUrl.startsWith(defaultSite.url)) return true;
    }

    // Check user-added sites
    for (final site in _sites) {
      if (site.baseUrl == requestBaseUrl) return true;
    }

    return false;
  }

  Future<void> _updateMissingMetadata() async {
    bool needsUpdate = false;
    for (int i = 0; i < _sites.length; i++) {
      if (_sites[i].faviconUrl == null || _sites[i].colorHex == null) {
        try {
          final metadata = await BrowserSiteService.fetchSiteMetadata(
            _sites[i].url,
          );
          _sites[i] = _sites[i].copyWith(
            faviconUrl: metadata.faviconUrl,
            colorHex: metadata.colorHex,
          );
          needsUpdate = true;
        } catch (e) {
          developer.log(
            'Error fetching metadata for ${_sites[i].url}: $e',
            name: 'BrowserScreenMetadata',
          );
        }
      }
    }
    if (needsUpdate) {
      await BrowserSiteService.saveSites(_sites);
      if (mounted) {
        setState(() {});
      }
    }
  }

  Widget _buildDialogTitle(
    BuildContext context, {
    required IconData icon,
    required String title,
    Color? containerColor,
    Color? iconColor,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: containerColor ?? colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: iconColor ?? colorScheme.onPrimaryContainer),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            title,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDialogInfoCard(
    BuildContext context, {
    required IconData icon,
    required String text,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.7),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: colorScheme.onSurfaceVariant),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _addSite() async {
    final titleController = TextEditingController();
    final urlController = TextEditingController();
    String? titleErrorText;
    String? urlErrorText;

    final navigator = Navigator.of(context);
    final scaffoldMessenger = ScaffoldMessenger.of(context);

    await showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (dialogContext, setStateDialog) {
          return AlertDialog(
            title: _buildDialogTitle(
              dialogContext,
              icon: Icons.add_link,
              title: 'サイトを追加',
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildDialogInfoCard(
                  dialogContext,
                  icon: Icons.info_outline,
                  text: 'よく使うサイトを登録すると、ブラウザ上部の切り替えからすぐに開けます。',
                ),
                const SizedBox(height: 16),
                BrowserSiteFormFields(
                  titleController: titleController,
                  urlController: urlController,
                  titleErrorText: titleErrorText,
                  urlErrorText: urlErrorText,
                  onTitleChanged: (_) {
                    if (titleErrorText != null) {
                      setStateDialog(() {
                        titleErrorText = null;
                      });
                    }
                  },
                  onUrlChanged: (_) {
                    if (urlErrorText != null) {
                      setStateDialog(() {
                        urlErrorText = null;
                      });
                    }
                  },
                ),
              ],
            ),
            actions: [
              ButtonM3E(
                style: ButtonM3EStyle.text,
                onPressed: () => Navigator.pop(dialogContext),
                icon: const Icon(Icons.close),
                label: const Text('キャンセル'),
              ),
              ButtonM3E(
                style: ButtonM3EStyle.text,
                onPressed: () async {
                  final title = titleController.text.trim();
                  final url = urlController.text.trim();
                  bool isValid = true;

                  setStateDialog(() {
                    titleErrorText = null;
                    urlErrorText = null;
                  });

                  if (title.isEmpty) {
                    titleErrorText = 'タイトルを入力してください';
                    isValid = false;
                  }
                  if (url.isEmpty) {
                    urlErrorText = 'URLを入力してください';
                    isValid = false;
                  }
                  if (!isValid) {
                    setStateDialog(() {});
                  } else {
                    // Check if site already exists
                    final existingDefault = BrowserConstants.defaultSites.any(
                      (defaultSite) =>
                          defaultSite.title == title && defaultSite.url == url,
                    );
                    if (existingDefault) {
                      scaffoldMessenger.showSnackBar(
                        SnackBar(content: Text('$titleは既に追加されています。')),
                      );
                      isValid = false;
                    }

                    if (isValid) {
                      final uri = Uri.tryParse(url);
                      if (uri == null || !uri.hasScheme || !uri.hasAuthority) {
                        setStateDialog(() {
                          urlErrorText =
                              '有効なURLを入力してください (例: https://example.com)';
                        });
                        isValid = false;
                      }
                    }
                  }

                  if (isValid) {
                    showDialog(
                      context: dialogContext,
                      barrierDismissible: false,
                      builder: (context) => const Center(
                        child: AppLoadingIndicator(semanticsLabel: 'サイト情報を取得中'),
                      ),
                    );
                    try {
                      final newSite = BrowserSite(title: title, url: url);
                      final metadata =
                          await BrowserSiteService.fetchSiteMetadata(url);
                      final siteWithMetadata = newSite.copyWithMetadata(
                        faviconUrl: metadata.faviconUrl,
                        colorHex: metadata.colorHex,
                      );

                      if (!mounted) {
                        if (navigator.mounted && navigator.canPop()) {
                          navigator.pop();
                        }
                        return;
                      }

                      if (navigator.mounted && navigator.canPop()) {
                        navigator.pop(); // Dismiss loading
                      }

                      _sites.add(siteWithMetadata);
                      await BrowserSiteService.saveSites(_sites);
                      if (mounted) {
                        setState(() {});
                      }
                      if (navigator.mounted && navigator.canPop()) {
                        navigator.pop(); // Close add dialog
                      }
                    } catch (e) {
                      if (navigator.mounted && navigator.canPop()) {
                        navigator.pop(); // Dismiss loading
                      }
                      developer.log(
                        'Error adding site $url: $e',
                        name: 'BrowserScreenAddSite',
                      );
                      if (mounted) {
                        scaffoldMessenger.showSnackBar(
                          SnackBar(content: Text('サイトメタデータの取得に失敗しました: $e')),
                        );
                      }
                    }
                  }
                },
                icon: const Icon(Icons.add_link),
                label: const Text('追加'),
              ),
            ],
          );
        },
      ),
    );
    titleController.dispose();
    urlController.dispose();
  }

  Future<void> _removeSite(int index) async {
    bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) {
        final colorScheme = Theme.of(context).colorScheme;

        return AlertDialog(
          title: _buildDialogTitle(
            context,
            icon: Icons.delete_outline,
            title: 'サイトを削除',
            containerColor: colorScheme.errorContainer,
            iconColor: colorScheme.onErrorContainer,
          ),
          content: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: colorScheme.errorContainer.withValues(alpha: 0.55),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '\'${_sites[index].title}\' を削除しますか？',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: colorScheme.onErrorContainer,
              ),
            ),
          ),
          actions: [
            ButtonM3E(
              style: ButtonM3EStyle.text,
              onPressed: () => Navigator.pop(context, false),
              icon: const Icon(Icons.close),
              label: const Text('キャンセル'),
            ),
            ButtonM3E(
              style: ButtonM3EStyle.text,
              onPressed: () => Navigator.pop(context, true),
              icon: Icon(Icons.delete_outline, color: colorScheme.error),
              label: Text(
                '削除',
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: colorScheme.error,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        );
      },
    );

    if (confirm == true) {
      _sites.removeAt(index);
      await BrowserSiteService.saveSites(_sites);
      if (mounted) {
        setState(() {});
      }
    }
  }

  Future<void> _editSite(int index) async {
    final site = _sites[index];
    final titleController = TextEditingController(text: site.title);
    final urlController = TextEditingController(text: site.url);
    String? titleErrorText;
    String? urlErrorText;

    final navigator = Navigator.of(context);

    await showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (dialogContext, setStateDialog) {
          return AlertDialog(
            title: _buildDialogTitle(
              dialogContext,
              icon: Icons.edit_outlined,
              title: 'サイトを編集',
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildDialogInfoCard(
                  dialogContext,
                  icon: Icons.public,
                  text: 'URLを変更した場合は、保存後にサイトのアイコンと色を再取得します。',
                ),
                const SizedBox(height: 16),
                BrowserSiteFormFields(
                  titleController: titleController,
                  urlController: urlController,
                  titleErrorText: titleErrorText,
                  urlErrorText: urlErrorText,
                  onTitleChanged: (_) {
                    if (titleErrorText != null) {
                      setStateDialog(() => titleErrorText = null);
                    }
                  },
                  onUrlChanged: (_) {
                    if (urlErrorText != null) {
                      setStateDialog(() => urlErrorText = null);
                    }
                  },
                ),
              ],
            ),
            actions: [
              ButtonM3E(
                style: ButtonM3EStyle.text,
                onPressed: () async {
                  Navigator.pop(dialogContext);
                  await _removeSite(index);
                },
                icon: Icon(
                  Icons.delete_outline,
                  color: Theme.of(dialogContext).colorScheme.error,
                ),
                label: Text(
                  '削除',
                  style: Theme.of(dialogContext).textTheme.labelLarge?.copyWith(
                    color: Theme.of(dialogContext).colorScheme.error,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              ButtonM3E(
                style: ButtonM3EStyle.text,
                onPressed: () => Navigator.pop(dialogContext),
                icon: const Icon(Icons.close),
                label: const Text('キャンセル'),
              ),
              ButtonM3E(
                style: ButtonM3EStyle.text,
                onPressed: () async {
                  final newTitle = titleController.text.trim();
                  final newUrl = urlController.text.trim();

                  setStateDialog(() {
                    titleErrorText = newTitle.isEmpty ? 'タイトルを入力してください' : null;
                    urlErrorText = newUrl.isEmpty ? 'URLを入力してください' : null;
                  });
                  if (titleErrorText != null || urlErrorText != null) {
                    return;
                  }

                  final uri = Uri.tryParse(newUrl);
                  if (uri == null || !uri.hasScheme || !uri.hasAuthority) {
                    setStateDialog(() {
                      urlErrorText = '有効なURLを入力してください。';
                    });
                    return;
                  }

                  final oldUrl = site.url;
                  final updatedSite = site.copyWith(
                    title: newTitle,
                    url: newUrl,
                    // Clear metadata if URL changed
                    faviconUrl: newUrl != oldUrl ? null : site.faviconUrl,
                    colorHex: newUrl != oldUrl ? null : site.colorHex,
                  );

                  _sites[index] = updatedSite;
                  await BrowserSiteService.saveSites(_sites);

                  if (mounted) setState(() {});

                  if (newUrl != oldUrl) {
                    _updateMissingMetadata();
                  }

                  if (navigator.mounted && navigator.canPop()) {
                    navigator.pop();
                  }
                },
                icon: const Icon(Icons.save_outlined),
                label: const Text('更新'),
              ),
            ],
          );
        },
      ),
    );
    titleController.dispose();
    urlController.dispose();
  }

  bool _isCurrentSite(String url) {
    if (_currentUrl == url || _currentUrl.startsWith(url)) return true;
    if (url == BrowserConstants.defaultSites[1].url) {
      return _currentUrl.startsWith(url);
    }
    final siteBaseUrl = Uri.tryParse(url)?.origin;
    final currentBaseUrl = Uri.tryParse(_currentUrl)?.origin;
    return siteBaseUrl != null && siteBaseUrl == currentBaseUrl;
  }

  Color _getTextColorForBackground(Color backgroundColor) {
    // Calculate luminance to determine if we should use light or dark text
    final luminance = backgroundColor.computeLuminance();
    return luminance > 0.5 ? Colors.black87 : Colors.white;
  }

  Widget _buildSiteButton({
    required String title,
    required String url,
    String? faviconUrl,
    String? colorHex,
    VoidCallback? onLongPress,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isSelected = _isControllerReady && _isCurrentSite(url);
    Color? backgroundColor;
    Color textColor = colorScheme.onSurfaceVariant;

    if (colorHex != null) {
      try {
        String hex = colorHex.replaceFirst('#', '');
        if (hex.length == 6) hex = 'FF$hex';
        if (hex.length == 8) {
          backgroundColor = Color(int.parse('0x$hex'));
          textColor = _getTextColorForBackground(backgroundColor);
        } else {
          throw const FormatException("Invalid hex color format");
        }
      } catch (e) {
        developer.log(
          'Error parsing color hex $colorHex: $e',
          name: 'BrowserScreenButton',
        );
        backgroundColor = colorScheme.surfaceContainerHighest;
        textColor = colorScheme.onSurfaceVariant;
      }
    } else {
      // デフォルトの背景色とテキスト色を設定
      backgroundColor = colorScheme.surfaceContainerHighest;
      textColor = colorScheme.onSurfaceVariant;

      // MaterialYou使用時はプライマリカラーで軽いティントを追加してコントラストを向上
      final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
      if (themeProvider.useMaterialYou) {
        backgroundColor = backgroundColor.withValues(alpha: 0.9);
      }
    }

    if (isSelected) {
      backgroundColor = colorScheme.primaryContainer;
      textColor = colorScheme.onPrimaryContainer;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
      child: Tooltip(
        message: onLongPress != null ? '$titleを開く（長押しで編集）' : '$titleを開く',
        child: Semantics(
          selected: isSelected,
          hint: onLongPress != null ? '長押しで編集できます' : null,
          child: FilledButton(
            onPressed: () async {
              String targetUrl = url;
              // AtCoder Problems の場合はユーザー名を付加する
              if (url == BrowserConstants.defaultSites[1].url) {
                final prefs = await SharedPreferences.getInstance();
                final username = prefs.getString('atcoder_username');
                if (username != null && username.isNotEmpty) {
                  targetUrl = '$url$username';
                }
              }

              if (_embeddedBrowserUnavailable) {
                await _openSiteExternally(targetUrl);
                return;
              }

              if (_currentUrl != targetUrl) {
                _currentUrl = targetUrl;
                if (mounted) {
                  setState(() {
                    _isLoadingWebView = true;
                    _loadFailed = false;
                  });
                }
                _controller.loadRequest(Uri.parse(targetUrl));
              } else {
                developer.log(
                  'Button pressed for already loaded URL: $url',
                  name: 'BrowserScreenButton',
                );
                // Optionally reload:
                // if (mounted) { setState(() { _isLoadingWebView = true; _loadFailed = false; }); }
                // _controller.reload();
              }
            },
            onLongPress: onLongPress,
            style: FilledButton.styleFrom(
              backgroundColor: backgroundColor,
              foregroundColor: textColor,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(999),
                side: BorderSide(
                  color: isSelected
                      ? colorScheme.primary.withValues(alpha: 0.35)
                      : Colors.transparent,
                ),
              ),
              elevation: isSelected ? 2 : 0,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (isSelected) ...[
                  Icon(Icons.check_circle, size: 16, color: textColor),
                  const SizedBox(width: 6),
                ],
                if (faviconUrl != null)
                  Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: textColor.withValues(alpha: 0.5),
                        width: 1.0,
                      ),
                    ),
                    child: ClipOval(
                      child: Image.network(
                        faviconUrl,
                        width: 20,
                        height: 20,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Icon(
                          Icons.public,
                          size: 18,
                          color: textColor.withValues(alpha: 0.8),
                        ),
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              value: loadingProgress.expectedTotalBytes != null
                                  ? loadingProgress.cumulativeBytesLoaded /
                                        loadingProgress.expectedTotalBytes!
                                  : null,
                            ),
                          );
                        },
                      ),
                    ),
                  )
                else
                  Icon(
                    Icons.public,
                    size: 18,
                    color: textColor.withValues(alpha: 0.8),
                  ),
                const SizedBox(width: 8),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 128),
                  child: Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: textColor,
                      fontWeight: isSelected
                          ? FontWeight.w700
                          : FontWeight.w500,
                    ),
                  ),
                ),
                if (_embeddedBrowserUnavailable) ...[
                  const SizedBox(width: 6),
                  Icon(Icons.open_in_new, size: 15, color: textColor),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSiteSwitcher() {
    return BrowserSiteSwitcher(
      scrollController: _siteScrollController,
      onAdd: _addSite,
      siteButtons: [
        ...BrowserConstants.defaultSites.map(
          (defaultSite) => _buildSiteButton(
            title: defaultSite.title,
            url: defaultSite.url,
            faviconUrl: defaultSite.faviconUrl,
            colorHex: defaultSite.colorHex,
          ),
        ),
        ..._sites.asMap().entries.map((entry) {
          final index = entry.key;
          final site = entry.value;
          return _buildSiteButton(
            title: site.title,
            url: site.url,
            faviconUrl: site.faviconUrl,
            colorHex: site.colorHex,
            onLongPress: () => _editSite(index),
          );
        }),
      ],
    );
  }

  Widget _buildBrowserStateOverlay({
    required IconData icon,
    required String title,
    required String message,
    bool isError = false,
    Widget? action,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final foregroundColor = colorScheme.onSurfaceVariant;
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
          child: ConstrainedBox(
            // 状態表示は短い説明と単一操作なので、デスクトップでも読み幅を
            // 必要以上に広げない。狭い画面では親の制約まで自然に縮む。
            constraints: const BoxConstraints(maxWidth: 640),
            child: Card(
              elevation: 3,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
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
                            borderRadius: BorderRadius.circular(8),
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
                                  color: isError ? colorScheme.onSurface : null,
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
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context); // AutomaticKeepAliveClientMixin を使うために必要
    return Column(
      children: [
        _buildSiteSwitcher(),
        Expanded(
          child: Stack(
            children: [
              if (_embeddedBrowserUnavailable)
                _buildBrowserStateOverlay(
                  icon: Icons.open_in_browser,
                  title: '埋め込み表示に対応していません',
                  message: 'この環境では、サイトを外部ブラウザで開きます。',
                  action: ResponsiveAction(
                    child: ButtonM3E(
                      style: ButtonM3EStyle.filled,
                      onPressed: () => _openSiteExternally(_currentUrl),
                      icon: const Icon(Icons.open_in_new),
                      label: const Text('外部で開く'),
                    ),
                  ),
                )
              else if (_isControllerReady)
                WebViewWidget(controller: _controller)
              else
                const Center(
                  child: AppLoadingIndicator(semanticsLabel: 'ブラウザを準備中'),
                ),

              if (_isControllerReady && _loadFailed)
                _buildBrowserStateOverlay(
                  icon: Icons.error_outline,
                  title: 'ページを読み込めませんでした',
                  message: _currentUrl,
                  isError: true,
                  action: ResponsiveAction(
                    child: ButtonM3E(
                      style: ButtonM3EStyle.filled,
                      onPressed: () {
                        if (mounted) {
                          setState(() {
                            _isLoadingWebView = true;
                            _loadFailed = false;
                          });
                        }
                        _controller.loadRequest(Uri.parse(_currentUrl));
                      },
                      icon: const Icon(Icons.refresh),
                      label: const Text('再試行'),
                    ),
                  ),
                ),

              if (_isControllerReady && _isLoadingWebView && !_loadFailed)
                _buildBrowserStateOverlay(
                  icon: Icons.public,
                  title: 'ページを読み込み中',
                  message: _currentUrl,
                  action: const Center(
                    child: AppLoadingIndicator(semanticsLabel: 'ページを読み込み中'),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}
