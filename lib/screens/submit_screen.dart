import 'dart:convert'; // for auto-paste code
import 'dart:developer'; // for JS debug messages

import 'package:flutter/material.dart';
import 'package:m3e_collection/m3e_collection.dart';
import 'package:webview_flutter/webview_flutter.dart';

class SubmitScreen extends StatefulWidget {
  final String url;
  final String initialCode;
  final String initialLanguage;
  const SubmitScreen({
    super.key,
    required this.url,
    required this.initialCode,
    required this.initialLanguage,
  });

  @override
  State<SubmitScreen> createState() => _SubmitScreenState();
}

class _SubmitScreenState extends State<SubmitScreen> {
  late final WebViewController _controller;
  int _loadingProgress = 0;
  bool _hasPageError = false;
  String _statusMessage = '提出ページを読み込んでいます';

  @override
  void initState() {
    super.initState();
    // JavaScript チャンネル追加（デバッグ用）
    _controller = WebViewController()
      ..addJavaScriptChannel(
        'Debug',
        onMessageReceived: (message) {
          log('JS> ${message.message}', name: 'SubmitScreen');
        },
      )
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (progress) {
            if (!mounted) return;
            setState(() {
              _loadingProgress = progress;
            });
          },
          onPageStarted: (_) {
            if (!mounted) return;
            setState(() {
              _hasPageError = false;
              _statusMessage = '提出ページを読み込んでいます';
            });
          },
          onPageFinished: (url) {
            _controller.runJavaScript('''(function() {
  // debug: select[name="language_id"] presence
  var sel = document.querySelector('select[name="language_id"]');
  window.Debug.postMessage('select[name="language_id"] found: ' + (sel !== null));
  if (sel) window.Debug.postMessage('selector name=' + sel.name + ', options=' + sel.options.length);
  // debug: list all select2 containers
  var sp = document.querySelectorAll('.select2-selection');
  window.Debug.postMessage('.select2-selection count: ' + sp.length);
            var desired = "Python (PyPy 3.10-v7.3.12)";
            var sel = document.getElementById('language_id');
            if (sel) {
    window.Debug.postMessage('options count: ' + sel.options.length);
              for (var i = 0; i < sel.options.length; i++) {
      window.Debug.postMessage('option['+i+'] text=' + sel.options[i].text);
                var opt = sel.options[i];
                if (opt.text.indexOf(desired) !== -1) {
        window.Debug.postMessage('matching option[' + i + ']= ' + opt.text);
                  sel.value = opt.value;
        window.Debug.postMessage('sel.value set to=' + sel.value);
                  sel.dispatchEvent(new Event('change', { bubbles: true }));
                  if (window.jQuery) {
                    jQuery(sel).val(opt.value).trigger('change');
                  }
                  var disp = document.querySelector('.select2-selection__rendered');
        window.Debug.postMessage('select2 display element: ' + (disp !== null));
                  if (disp) disp.textContent = opt.text;
                  break;
                }
              }
            }
  window.Debug.postMessage('language selection script finished');
            var code = ${jsonEncode(widget.initialCode)};
            var ta = document.querySelector('textarea[name=sourceCode]');
            if (ta) {
    window.Debug.postMessage('textarea found');
              ta.value = code;
              ta.dispatchEvent(new Event('input', { bubbles: true }));
            }
            if (window.ace && document.querySelector('.ace_editor')) {
    window.Debug.postMessage('ace editor found');
              var ed = ace.edit(document.querySelector('.ace_editor'));
              ed.setValue(code, -1);
              ed.clearSelection();
            }
})();''');
            if (!mounted) return;
            setState(() {
              _statusMessage = 'コードを提出フォームへ自動入力しました';
              _loadingProgress = 100;
            });
          },
          onWebResourceError: (error) {
            if (!mounted || error.isForMainFrame == false) return;
            setState(() {
              _hasPageError = true;
              _statusMessage = '提出ページを読み込めませんでした';
            });
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.url));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarM3E(
        title: const Text('提出'),
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
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            _buildStatusHeader(context),
            Expanded(child: WebViewWidget(controller: _controller)),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusHeader(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final progress = (_loadingProgress / 100).clamp(0.0, 1.0);
    final foregroundColor = colorScheme.onSurfaceVariant;
    final iconBackground = _hasPageError
        ? colorScheme.errorContainer
        : colorScheme.primaryContainer;
    final iconColor = _hasPageError
        ? colorScheme.onErrorContainer
        : colorScheme.onPrimaryContainer;

    return Card(
      elevation: 2,
      margin: const EdgeInsets.fromLTRB(12, 8, 12, 8),
      color: _hasPageError
          ? Color.alphaBlend(
              colorScheme.errorContainer.withValues(alpha: 0.18),
              colorScheme.surface,
            )
          : null,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: _hasPageError
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
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    _hasPageError
                        ? Icons.error_outline
                        : Icons.cloud_upload_outlined,
                    color: iconColor,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _statusMessage,
                        style: theme.textTheme.titleSmall?.copyWith(
                          color: _hasPageError ? colorScheme.onSurface : null,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${widget.initialLanguage} / ${widget.initialCode.length}文字',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: foregroundColor,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
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
            if (!_hasPageError && _loadingProgress < 100) ...[
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
}
