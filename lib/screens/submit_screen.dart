import 'dart:convert'; // for auto-paste code
import 'dart:developer'; // for JS debug messages

import 'package:flutter/material.dart';
import 'package:m3e_collection/m3e_collection.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../widgets/shared/web_content_status_header.dart';

/// 提出用WebViewで許可する遷移と、コードを注入してよいページを判定する。
///
/// 初期URLだけを信頼すると、リダイレクトやリンク遷移後の別オリジンへ
/// エディタ内容を渡してしまうため、遷移時と注入直前の両方で検証する。
abstract final class SubmitNavigationPolicy {
  static bool isAllowedAtCoderUrl(String url) {
    final uri = Uri.tryParse(url);
    return uri != null &&
        uri.scheme == 'https' &&
        uri.host == 'atcoder.jp' &&
        !uri.hasPort &&
        uri.userInfo.isEmpty;
  }

  static bool isSubmissionPage(String url) {
    if (!isAllowedAtCoderUrl(url)) return false;
    final segments = Uri.parse(url).pathSegments;
    return segments.length == 3 &&
        segments[0] == 'contests' &&
        segments[1].isNotEmpty &&
        segments[2] == 'submit';
  }
}

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
            // ログイン等のAtCoder内ページは遷移を許可するが、ソースコードを
            // DOMへ渡すのは提出ページだけに限定する。
            if (!SubmitNavigationPolicy.isSubmissionPage(url)) return;
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
          onNavigationRequest: (request) {
            // 外部オリジンへの遷移をWebView内で継続させると、そのページの
            // DOMへ提出コードを注入する境界が再び生じるため、常に遮断する。
            return SubmitNavigationPolicy.isAllowedAtCoderUrl(request.url)
                ? NavigationDecision.navigate
                : NavigationDecision.prevent;
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
            onPressed: _reload,
          ),
        ],
      ),
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            WebContentStatusHeader(
              statusMessage: _statusMessage,
              detail:
                  '${widget.initialLanguage} / ${widget.initialCode.length}文字',
              icon: Icons.cloud_upload_outlined,
              loadingProgress: _loadingProgress,
              isLoading: !_hasPageError && _loadingProgress < 100,
              hasError: _hasPageError,
              progressSemanticsLabel: '提出ページの読み込み進捗',
              onRetry: _reload,
            ),
            Expanded(child: WebViewWidget(controller: _controller)),
          ],
        ),
      ),
    );
  }

  void _reload() {
    setState(() {
      _loadingProgress = 0;
      _hasPageError = false;
      _statusMessage = '提出ページを読み込んでいます';
    });
    _controller.reload();
  }
}
