import 'dart:developer' as developer;

import 'package:flutter/material.dart';
import 'package:m3e_collection/m3e_collection.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../constants/browser_constants.dart';
import '../models/browser_site.dart';
import '../providers/theme_provider.dart';
import '../services/browser_site_service.dart';
import '../widgets/shared/app_loading_indicator.dart';

class BrowserScreen extends StatefulWidget {
  final Function(String) navigateToProblem;

  const BrowserScreen({super.key, required this.navigateToProblem});

  @override
  State<BrowserScreen> createState() => _BrowserScreenState();
}

class _BrowserScreenState extends State<BrowserScreen>
    with AutomaticKeepAliveClientMixin {
  late WebViewController _controller;
  List<BrowserSite> _sites = [];
  bool _isControllerReady = false;
  bool _loadFailed = false;
  String _currentUrl = '';
  bool _isLoadingWebView = false;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    _sites = await BrowserSiteService.loadSites();
    final prefs = await SharedPreferences.getInstance();
    final atcoderUsername = prefs.getString('atcoder_username');

    // Initialize WebViewController
    String initialUrl = BrowserConstants.defaultSites.first.url;
    // If first site is Problems, append username
    if (initialUrl == BrowserConstants.defaultSites[1].url &&
        atcoderUsername != null &&
        atcoderUsername.isNotEmpty) {
      initialUrl = '${BrowserConstants.defaultSites[1].url}$atcoderUsername';
    }

    _currentUrl = initialUrl;
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
          onNavigationRequest: (NavigationRequest request) {
            return _handleNavigationRequest(request);
          },
        ),
      )
      ..loadRequest(Uri.parse(initialUrl));

    _isControllerReady = true;
    if (mounted) {
      setState(() {});
    }

    // Update missing metadata for user-added sites
    _updateMissingMetadata();
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
            borderRadius: BorderRadius.circular(12),
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
        borderRadius: BorderRadius.circular(12),
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

  InputDecoration _buildDialogInputDecoration(
    BuildContext context, {
    required String labelText,
    required IconData prefixIcon,
    String? errorText,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: colorScheme.outlineVariant),
    );

    return InputDecoration(
      labelText: labelText,
      errorText: errorText,
      prefixIcon: Icon(prefixIcon),
      filled: true,
      fillColor: colorScheme.surfaceContainerHighest.withValues(alpha: 0.35),
      border: border,
      enabledBorder: border,
      focusedBorder: border.copyWith(
        borderSide: BorderSide(color: colorScheme.primary, width: 1.6),
      ),
      errorBorder: border.copyWith(
        borderSide: BorderSide(color: colorScheme.error),
      ),
      focusedErrorBorder: border.copyWith(
        borderSide: BorderSide(color: colorScheme.error, width: 1.6),
      ),
    );
  }

  Future<void> _addSite() async {
    final titleController = TextEditingController();
    final urlController = TextEditingController();
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
                TextField(
                  controller: titleController,
                  decoration: _buildDialogInputDecoration(
                    dialogContext,
                    labelText: 'タイトル',
                    prefixIcon: Icons.label_outline,
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: urlController,
                  decoration: _buildDialogInputDecoration(
                    dialogContext,
                    labelText: 'URL',
                    prefixIcon: Icons.link,
                    errorText: urlErrorText,
                  ),
                  keyboardType: TextInputType.url,
                  onChanged: (_) {
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
                    urlErrorText = null;
                  });

                  if (title.isEmpty || url.isEmpty) {
                    scaffoldMessenger.showSnackBar(
                      const SnackBar(content: Text('タイトルとURLを入力してください。')),
                    );
                    isValid = false;
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
              borderRadius: BorderRadius.circular(12),
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
              label: const Text('キャンセル'),
            ),
            ButtonM3E(
              style: ButtonM3EStyle.text,
              onPressed: () => Navigator.pop(context, true),
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
                TextField(
                  controller: titleController,
                  decoration: _buildDialogInputDecoration(
                    dialogContext,
                    labelText: 'タイトル',
                    prefixIcon: Icons.label_outline,
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: urlController,
                  decoration: _buildDialogInputDecoration(
                    dialogContext,
                    labelText: 'URL',
                    prefixIcon: Icons.link,
                    errorText: urlErrorText,
                  ),
                  keyboardType: TextInputType.url,
                  onChanged: (_) {
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

                  if (newTitle.isEmpty || newUrl.isEmpty) {
                    setStateDialog(() {
                      urlErrorText = 'タイトルとURLを入力してください。';
                    });
                    return;
                  }

                  final uri = Uri.tryParse(newUrl);
                  if (uri == null || !uri.hasScheme || !uri.hasAuthority) {
                    setStateDialog(() => urlErrorText = '有効なURLを入力してください。');
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
    final isSelected = _isCurrentSite(url);
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
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSiteSwitcher() {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      elevation: 2,
      margin: const EdgeInsets.fromLTRB(12, 8, 12, 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      clipBehavior: Clip.antiAlias,
      child: SizedBox(
        height: 56,
        child: Row(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                scrollDirection: Axis.horizontal,
                children: [
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
              ),
            ),
            Container(width: 1, height: 28, color: colorScheme.outlineVariant),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: IconButtonM3E(
                tooltip: 'サイトを追加',
                icon: const Icon(Icons.add),
                onPressed: _addSite,
              ),
            ),
          ],
        ),
      ),
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
              if (_isControllerReady)
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
                  action: SizedBox(
                    width: double.infinity,
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
