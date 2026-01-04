import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_monaco/flutter_monaco.dart';

/// Monaco Editor wrapper widget for the editor screen.
/// This provides VS Code-like editing experience.
class MonacoCodeEditor extends StatefulWidget {
  const MonacoCodeEditor({
    super.key,
    required this.initialValue,
    required this.language,
    required this.isDarkMode,
    required this.onChanged,
  });

  final String initialValue;
  final String language;
  final bool isDarkMode;
  final ValueChanged<String> onChanged;

  @override
  State<MonacoCodeEditor> createState() => MonacoCodeEditorState();
}

class MonacoCodeEditorState extends State<MonacoCodeEditor> {
  MonacoController? _controller;
  bool _isInitialized = false;
  bool _isDisposed = false;
  String _currentValue = '';

  // ソフトキーボード表示用の隠し TextField 用
  final FocusNode _keyboardFocusNode = FocusNode(
    debugLabel: 'monaco_keyboard_bridge',
  );
  final TextEditingController _keyboardTextController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _currentValue = widget.initialValue;
    _initializeEditor();
  }

  Future<void> _initializeEditor() async {
    if (_isDisposed) return;

    try {
      _controller = await MonacoController.create(
        options: EditorOptions(
          language: _getMonacoLanguage(widget.language),
          theme: widget.isDarkMode ? MonacoTheme.vsDark : MonacoTheme.vs,
          fontSize: 14,
          minimap: false, // Disable minimap for mobile
          lineNumbers: true,
          wordWrap: false,
          automaticLayout: true,
          tabSize: 4,
          insertSpaces: true,
          scrollBeyondLastLine: false,
          renderWhitespace: RenderWhitespace.selection,
          bracketPairColorization: true,
          quickSuggestions: true,
          parameterHints: true,
          readOnly: false,
        ),
      );

      if (_isDisposed) {
        _controller?.dispose();
        return;
      }

      // Set initial value
      await _controller!.setValue(widget.initialValue);

      // 初期表示時にフォーカスを試みる
      // await _controller!.focus();

      // Listen to content changes
      _controller!.onContentChanged.listen((isFlush) async {
        if (_isDisposed) return;
        final value = await _controller!.getValue();
        if (value != _currentValue) {
          _currentValue = value;
          widget.onChanged(value);
        }
      });

      // Listen to focus events for debugging
      _controller!.onFocus.listen((_) {
        debugPrint('Monaco Editor focused');
      });

      _controller!.onBlur.listen((_) {
        debugPrint('Monaco Editor blurred');
      });

      if (mounted && !_isDisposed) {
        setState(() {
          _isInitialized = true;
        });
      }
    } catch (e) {
      debugPrint('Failed to initialize Monaco Editor: $e');
    }
  }

  MonacoLanguage _getMonacoLanguage(String language) {
    switch (language) {
      case 'Python':
        return MonacoLanguage.python;
      case 'C++':
        return MonacoLanguage.cpp;
      case 'Rust':
        return MonacoLanguage.rust;
      case 'Java':
        return MonacoLanguage.java;
      default:
        return MonacoLanguage.plaintext;
    }
  }

  @override
  void didUpdateWidget(MonacoCodeEditor oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (_controller != null && _isInitialized) {
      // Update language if changed
      if (oldWidget.language != widget.language) {
        _controller!.setLanguage(_getMonacoLanguage(widget.language));
      }

      // Update theme if changed
      if (oldWidget.isDarkMode != widget.isDarkMode) {
        _controller!.setTheme(
          widget.isDarkMode ? MonacoTheme.vsDark : MonacoTheme.vs,
        );
      }
    }
  }

  @override
  void dispose() {
    _isDisposed = true;
    _keyboardFocusNode.dispose();
    _keyboardTextController.dispose();
    _controller?.dispose();
    super.dispose();
  }

  /// Get the current code value
  Future<String> getValue() async {
    if (_controller != null && _isInitialized) {
      return await _controller!.getValue();
    }
    return _currentValue;
  }

  /// Set the code value
  Future<void> setValue(String value) async {
    _currentValue = value;
    if (_controller != null && _isInitialized) {
      await _controller!.setValue(value);
    }
  }

  /// Get the current value synchronously (from cache)
  String get currentValue => _currentValue;

  /// Request focus on the editor to show keyboard
  Future<void> focus() async {
    if (_controller != null && _isInitialized) {
      await _controller!.focus();
    }
  }

  @override
  Widget build(BuildContext context) {
    // Check if platform is supported
    if (!_isPlatformSupported()) {
      return _buildUnsupportedPlatformMessage();
    }

    if (!_isInitialized || _controller == null) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Monaco Editor を初期化中...'),
          ],
        ),
      );
    }

    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 2.0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(4.0),
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () async {
            // Monaco にフォーカスを当てる
            if (_controller != null && _isInitialized) {
              await _controller!.focus();
            }

            // モバイルでは TextInput 経由でキーボードを表示させる
            if (Platform.isAndroid || Platform.isIOS) {
              // すでにフォーカス済みなら何もしない
              if (!_keyboardFocusNode.hasFocus) {
                FocusScope.of(context).requestFocus(_keyboardFocusNode);
              }
            }
          },
          child: Stack(
            fit: StackFit.expand,
            children: [
              _controller!.webViewWidget,

              // モバイル向け: 画面外に配置した隠し TextField でソフトキーボードを開かせる
              if (Platform.isAndroid || Platform.isIOS)
                Positioned(
                  // 画面外に出す
                  left: -1000,
                  top: -1000,
                  width: 0,
                  height: 0,
                  child: EditableText(
                    controller: _keyboardTextController,
                    focusNode: _keyboardFocusNode,
                    style: const TextStyle(fontSize: 1),
                    cursorColor: Colors.transparent,
                    backgroundCursorColor: Colors.transparent,
                    keyboardType: TextInputType.text,
                    autofocus: false,
                    inputFormatters: [
                      // ここで入力を Monaco 側に転送する
                      TextInputFormatter.withFunction((oldValue, newValue) {
                        final inserted = newValue.text.replaceFirst(
                          oldValue.text,
                          '',
                        );
                        if (inserted.isNotEmpty &&
                            _controller != null &&
                            _isInitialized) {
                          // flutter_monaco には直接 type API がないため、
                          // 現在値に追記して setValue する方式で入力を転送する
                          _controller!.getValue().then((current) {
                            if (_isDisposed) return;
                            _controller!.setValue(current + inserted);
                          });
                        }
                        // TextField 自体には文字を溜めない
                        return const TextEditingValue();
                      }),
                    ],
                  ),
                ),

              // Focus guard for desktop platforms to handle focus issues
              if (Platform.isWindows || Platform.isMacOS || Platform.isLinux)
                MonacoFocusGuard(controller: _controller!),
            ],
          ),
        ),
      ),
    );
  }

  bool _isPlatformSupported() {
    // Monaco Editor supports Android, iOS, macOS, Windows
    // Web and Linux are not supported
    return Platform.isAndroid ||
        Platform.isIOS ||
        Platform.isMacOS ||
        Platform.isWindows;
  }

  Widget _buildUnsupportedPlatformMessage() {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 2.0),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.warning_amber_rounded,
                size: 48,
                color: Theme.of(context).colorScheme.error,
              ),
              const SizedBox(height: 16),
              Text(
                'Monaco Editor はこのプラットフォームでサポートされていません',
                style: Theme.of(context).textTheme.titleMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                '設定から「従来のエディタ」を選択してください',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
