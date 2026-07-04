import 'dart:async';

import 'package:flutter/material.dart';
import 'package:m3e_collection/m3e_collection.dart';
import 'package:url_launcher/url_launcher.dart';

import '../services/enhanced_update_service.dart';
import '../services/update_manager.dart';

class UpdateProgressDialog extends StatefulWidget {
  final EnhancedAppUpdateInfo updateInfo;
  final VoidCallback? onCompleted;
  final VoidCallback? onCancelled;

  const UpdateProgressDialog({
    super.key,
    required this.updateInfo,
    this.onCompleted,
    this.onCancelled,
  });

  @override
  State<UpdateProgressDialog> createState() => _UpdateProgressDialogState();
}

class _UpdateProgressDialogState extends State<UpdateProgressDialog> {
  final EnhancedUpdateService _updateService = EnhancedUpdateService();
  final UpdateManager _updateManager = UpdateManager();
  StreamSubscription<UpdateProgress>? _progressSubscription;

  UpdateProgress? _currentProgress;
  bool _isDownloading = false;
  bool _isCompleted = false;
  bool _hasError = false;
  bool _isInitialized = false; // 初期化フラグを追加
  String? _downloadedFilePath;
  @override
  void initState() {
    super.initState();
    // Theme.of(context)を使用する処理はdidChangeDependenciesに移動
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // 初回実行時のみアップデートチェックを開始
    if (!_isInitialized && !_isDownloading && !_isCompleted && !_hasError) {
      _isInitialized = true;
      // 初期プログレス状態を設定
      setState(() {
        _currentProgress = UpdateProgress(progress: 0.0, status: '準備中...');
      });
      _startDownload();
    }
  }

  @override
  void dispose() {
    _progressSubscription?.cancel();
    _updateService.disposeProgressStream();
    super.dispose();
  }

  void _startDownload() async {
    if (!UpdateManager.kEnableSelfUpdate) {
      if (mounted) {
        setState(() {
          _hasError = true;
          _currentProgress = UpdateProgress(
            progress: 0.0,
            status: 'F-Droidビルドではアプリ内アップデートは無効です',
            errorMessage: 'GitHubのリリースページから手動でダウンロードしてください。',
          );
        });
      }
      return;
    }
    setState(() {
      _isDownloading = true;
      _hasError = false;
    });

    // キャッシュを使用するため権限チェックは不要
    // アプリ内部ストレージを使用するため、Androidでも権限は必要ない
    debugPrint('Starting download using cache (no permissions required)');

    // プログレスストリームを初期化
    _updateService.initializeProgressStream();

    // Listen to progress stream
    _progressSubscription = _updateService.progressStream?.listen(
      (progress) {
        //debugPrint('[UpdateProgressDialog] Progress received: ${progress.status} - ${progress.progress * 100}%');
        if (mounted) {
          setState(() {
            _currentProgress = progress;
            if (progress.isCompleted) {
              _isCompleted = true;
              _isDownloading = false;
            }
            if (progress.errorMessage != null) {
              _hasError = true;
              _isDownloading = false;
            }
          });
          // debugPrint('[UpdateProgressDialog] UI updated with progress: ${progress.status}');
        }
      },
      onError: (error) {
        debugPrint('[UpdateProgressDialog] Progress stream error: $error');
        if (mounted) {
          setState(() {
            _hasError = true;
            _isDownloading = false;
            _currentProgress = UpdateProgress(
              progress: 0.0,
              status: 'エラーが発生しました',
              errorMessage: error.toString(),
            );
          });
        }
      },
    ); // Start download
    try {
      // アップデート試行を記録
      await _updateService.markUpdateAttempt(widget.updateInfo.version);

      _downloadedFilePath = await _updateService.downloadUpdateWithProgress(
        widget.updateInfo,
      );
      if (_downloadedFilePath != null && mounted) {
        // インストール前にファイルを適切な場所に準備
        setState(() {
          _currentProgress = UpdateProgress(
            progress: 1.0,
            status: 'インストール準備中...',
            isCompleted: false,
          );
        });

        try {
          await Future.delayed(
            const Duration(milliseconds: 500),
          ); // APKインストール用にファイルを準備
          debugPrint('Installing from downloaded path: $_downloadedFilePath');

          try {
            await _updateManager.applyUpdate(
              _downloadedFilePath!,
              widget.updateInfo.assetName,
            );

            if (mounted) {
              setState(() {
                _currentProgress = UpdateProgress(
                  progress: 1.0,
                  status: 'インストールを開始しました',
                  isCompleted: true,
                );
              });
            }

            // 手動インストールの場合はダイアログを表示せずに終了
            debugPrint('Update installation process completed');
          } catch (installError) {
            // インストールエラーの場合、手動インストールガイダンスを表示
            debugPrint(
              'Installation failed, showing manual install guide: $installError',
            );
            if (mounted) {
              setState(() {
                _hasError = true;
                _currentProgress = UpdateProgress(
                  progress: 1.0,
                  status: 'アップデートファイル準備完了',
                  errorMessage: 'ファイルは準備できました。手動でインストールしてください。',
                );
              });

              // 手動インストールガイダンスを表示
              _showManualInstallDialog(installError.toString());
            }
            return; // 手動インストールガイダンス表示後は早期リターン
          }
        } catch (e) {
          debugPrint('Installation preparation error: $e');
          if (mounted) {
            setState(() {
              _hasError = true;
              _currentProgress = UpdateProgress(
                progress: 1.0,
                status: 'インストール準備エラー',
                errorMessage: e.toString(),
              );
            });

            // 手動インストールガイダンスを表示
            _showManualInstallDialog(e.toString());
          }
          return; // エラー時は早期リターン
        }

        // Close dialog after successful installation
        await Future.delayed(const Duration(seconds: 2));
        if (mounted) {
          Navigator.of(context).pop();
          widget.onCompleted?.call();
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _hasError = true;
          _isDownloading = false;
          _currentProgress = UpdateProgress(
            progress: 0.0,
            status: 'ダウンロードエラー',
            errorMessage: e.toString(),
          );
        });
      }
    }
  }

  void _retryDownload() {
    _updateService.disposeProgressStream();
    setState(() {
      _hasError = false;
      _isCompleted = false;
      _currentProgress = null;
    });
    _startDownload();
  }

  void _cancelDownload() {
    debugPrint('[UpdateProgressDialog] Cancel download requested');
    _progressSubscription?.cancel();
    _updateService.disposeProgressStream();
    Navigator.of(context).pop();
    widget.onCancelled?.call();
  }

  // 手動インストールガイダンスダイアログを表示
  void _showManualInstallDialog(String errorMessage) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        final theme = Theme.of(context);
        final colorScheme = theme.colorScheme;

        return AlertDialog(
          title: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.download_done,
                  color: colorScheme.onPrimaryContainer,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'ダウンロード完了',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.check_circle,
                        color: colorScheme.onPrimaryContainer,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'アップデートファイルのダウンロードが完了しました！',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: colorScheme.onPrimaryContainer,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'あと少しでアップデートが完了します。ファイルマネージャーでAPKファイルをタップしてインストールしてください。',
                  style: theme.textTheme.bodyMedium?.copyWith(height: 1.5),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerHighest.withValues(
                      alpha: 0.45,
                    ),
                    borderRadius: BorderRadius.circular(8),
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
                            Icons.touch_app,
                            color: colorScheme.onSurfaceVariant,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '簡単手順:',
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '1. 下の「ファイルを開く」ボタンをタップ\n'
                        '2. 「app-arm64-v8a-release.apk」をタップ\n'
                        '3. 「インストール」をタップ\n'
                        '4. インストール完了！',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: colorScheme.tertiaryContainer.withValues(
                      alpha: 0.55,
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.security,
                            color: colorScheme.onTertiaryContainer,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '権限が必要な場合:',
                            style: theme.textTheme.titleSmall?.copyWith(
                              color: colorScheme.onTertiaryContainer,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '「不明なアプリのインストールを許可しますか？」と表示されたら「許可」をタップしてください。',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.onTertiaryContainer,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton.icon(
              onPressed: () {
                Navigator.of(context).pop(); // ガイダンスダイアログを閉じる
                Navigator.of(context).pop(); // アップデートダイアログも閉じる
                widget.onCancelled?.call();
              },
              icon: const Icon(Icons.schedule),
              label: const Text('後で手動で実行'),
            ),
            FilledButton.icon(
              onPressed: () async {
                Navigator.of(context).pop(); // ガイダンスダイアログを閉じる
                Navigator.of(context).pop(); // アップデートダイアログも閉じる

                // ファイルマネージャーを開く
                try {
                  // 端末のファイルマネージャを開く。直接アプリ固有パスに依存しない形に変更。
                  final Uri directoryUri = Uri.parse(
                    'content://com.android.externalstorage.documents/document/primary:',
                  );
                  final launched = await launchUrl(
                    directoryUri,
                    mode: LaunchMode.externalApplication,
                  );

                  if (!launched) {
                    // フォールバック: 一般的なファイルマネージャーを開く
                    await launchUrl(
                      Uri.parse(
                        'content://com.android.externalstorage.documents/document/primary:',
                      ),
                      mode: LaunchMode.externalApplication,
                    );
                  }
                } catch (e) {
                  debugPrint('Failed to open file manager: $e');
                  // 最後の手段：設定アプリを開く
                  try {
                    await launchUrl(
                      Uri.parse(
                        'android.settings.APPLICATION_DETAILS_SETTINGS',
                      ),
                      mode: LaunchMode.externalApplication,
                    );
                  } catch (settingsError) {
                    debugPrint('Failed to open settings: $settingsError');
                  }
                }

                widget.onCompleted?.call();
              },
              icon: const Icon(Icons.folder_open),
              label: const Text('ファイルを開く'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return PopScope(
      canPop: !_isDownloading,
      child: AlertDialog(
        title: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.download,
                color: colorScheme.onPrimaryContainer,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'アップデートダウンロード',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
        content: SizedBox(
          width: double.maxFinite,
          height: MediaQuery.of(context).size.height * 0.6, // 画面の60%の高さに制限
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Version info
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerHighest.withValues(
                      alpha: 0.45,
                    ),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: colorScheme.outlineVariant.withValues(alpha: 0.7),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'バージョン ${widget.updateInfo.version}',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      if (widget.updateInfo.fileSize != null)
                        Text(
                          'ファイルサイズ: ${(widget.updateInfo.fileSize! / 1024 / 1024).toStringAsFixed(1)} MB',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                // Progress section
                Text(
                  _currentProgress?.status ?? '準備中...',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),

                // Progress bar
                if (_currentProgress?.progress != null &&
                    _currentProgress!.progress >= 0)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(999),
                    child: LinearProgressIndicator(
                      value: _currentProgress!.progress,
                      minHeight: 6,
                      backgroundColor: colorScheme.surfaceContainerHighest,
                    ),
                  )
                else
                  ClipRRect(
                    borderRadius: BorderRadius.circular(999),
                    child: LinearProgressIndicator(
                      minHeight: 6,
                      backgroundColor: colorScheme.surfaceContainerHighest,
                    ),
                  ), // Indeterminate

                const SizedBox(height: 8),

                // Progress text
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _currentProgress?.formattedProgress ?? '0.0%',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    if (_currentProgress?.progress != null &&
                        _currentProgress!.progress >= 0)
                      Text(
                        '${(_currentProgress!.progress * 100).toStringAsFixed(0)}%',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                  ],
                ),

                // Error message - 表示を制限
                if (_hasError && _currentProgress?.errorMessage != null) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: colorScheme.errorContainer,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.error_outline,
                              color: colorScheme.onErrorContainer,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'エラーが発生しました',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: colorScheme.onErrorContainer,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Container(
                          constraints: const BoxConstraints(
                            maxHeight: 100,
                          ), // エラーメッセージの高さを制限
                          child: SingleChildScrollView(
                            child: Text(
                              _currentProgress!.errorMessage!,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: colorScheme.onErrorContainer,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                // Success message
                if (_isCompleted && !_hasError) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.check_circle_outline,
                          color: colorScheme.onPrimaryContainer,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'ダウンロード完了！インストールを開始します。',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: colorScheme.onPrimaryContainer,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
        actions: [
          // Cancel button (always show unless completed)
          if (!_isCompleted)
            TextButton.icon(
              onPressed: _cancelDownload,
              icon: const Icon(Icons.close),
              label: const Text('キャンセル'),
            ),

          // Retry button (only show on error)
          if (_hasError)
            TextButton.icon(
              onPressed: _retryDownload,
              icon: const Icon(Icons.refresh),
              label: const Text('再試行'),
            ),

          // Close button (only show when completed or error)
          if ((_isCompleted && !_isDownloading) || _hasError)
            FilledButton.icon(
              onPressed: () {
                Navigator.of(context).pop();
                if (_isCompleted) {
                  widget.onCompleted?.call();
                }
              },
              icon: const Icon(Icons.check),
              label: const Text('閉じる'),
            ),
        ],
      ),
    );
  }
}

// Enhanced Update Notification Dialog (like ReVanced Manager)
class EnhancedUpdateDialog extends StatelessWidget {
  final EnhancedAppUpdateInfo updateInfo;
  final VoidCallback? onUpdatePressed;
  final VoidCallback? onLaterPressed;
  final VoidCallback? onSkipPressed;

  const EnhancedUpdateDialog({
    super.key,
    required this.updateInfo,
    this.onUpdatePressed,
    this.onLaterPressed,
    this.onSkipPressed,
  });
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    // Ensure version string has 'v' prefix for URL
    String versionTag = updateInfo.releaseTag ?? updateInfo.version;
    if (!versionTag.startsWith('v')) {
      versionTag = 'v$versionTag';
    }

    return AlertDialog(
      title: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.system_update_alt,
              color: colorScheme.onPrimaryContainer,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              "アップデート利用可能",
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Version info card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "新しいバージョン",
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: colorScheme.onPrimaryContainer,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      "v${updateInfo.version}",
                      style: theme.textTheme.headlineSmall?.copyWith(
                        color: colorScheme.onPrimaryContainer,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (updateInfo.releaseDate != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        "リリース日: ${updateInfo.releaseDate!.year}/${updateInfo.releaseDate!.month}/${updateInfo.releaseDate!.day}",
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.onPrimaryContainer,
                        ),
                      ),
                    ],
                    if (updateInfo.fileSize != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        "ファイルサイズ: ${(updateInfo.fileSize! / 1024 / 1024).toStringAsFixed(1)} MB",
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.onPrimaryContainer,
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Release notes
              if (updateInfo.releaseNotes != null &&
                  updateInfo.releaseNotes!.isNotEmpty) ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerHighest.withValues(
                      alpha: 0.45,
                    ),
                    borderRadius: BorderRadius.circular(8),
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
                            Icons.notes_outlined,
                            size: 18,
                            color: colorScheme.onSurfaceVariant,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            "リリースノート",
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      ConstrainedBox(
                        constraints: const BoxConstraints(maxHeight: 200),
                        child: SingleChildScrollView(
                          child: Text(
                            updateInfo.releaseNotes!,
                            style: theme.textTheme.bodyMedium,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ] else ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerHighest.withValues(
                      alpha: 0.45,
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.notes_outlined,
                        size: 18,
                        color: colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          "リリースノートはありません。",
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: colorScheme.secondaryContainer.withValues(alpha: 0.55),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      size: 18,
                      color: colorScheme.onSecondaryContainer,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'アップデートを開始するとダウンロード画面へ進みます。',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSecondaryContainer,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        // Later button
        ButtonM3E(
          style: ButtonM3EStyle.text,
          onPressed: () {
            Navigator.of(context).pop();
            onLaterPressed?.call();
          },
          icon: const Icon(Icons.schedule),
          label: const Text('後で'),
        ),
        if (onSkipPressed != null)
          ButtonM3E(
            style: ButtonM3EStyle.text,
            onPressed: () {
              Navigator.of(context).pop();
              onSkipPressed?.call();
            },
            icon: const Icon(Icons.skip_next_outlined),
            label: const Text('スキップ'),
          ),
        // View on GitHub button
        ButtonM3E(
          style: ButtonM3EStyle.text,
          onPressed: () async {
            final String releaseUrl =
                "https://github.com/Shojin-App/Shojin_App/releases/tag/$versionTag";
            await launchUrl(
              Uri.parse(releaseUrl),
              mode: LaunchMode.externalApplication,
            );
            if (context.mounted) Navigator.of(context).pop();
          },
          icon: const Icon(Icons.open_in_new),
          label: const Text('GitHub'),
        ),

        // Update button
        ButtonM3E(
          style: ButtonM3EStyle.filled,
          onPressed: () {
            Navigator.of(context).pop();
            onUpdatePressed?.call();
          },
          icon: const Icon(Icons.download),
          label: const Text('更新'),
        ),
      ],
    );
  }
}
