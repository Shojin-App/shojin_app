import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // For haptic feedback
import 'package:flutter_svg/flutter_svg.dart'; // For SVG icons
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart'; // For settings persistence
import 'package:url_launcher/url_launcher.dart'; // For launching URLs

import '../config/build_config.dart'; // Import build configuration
import '../providers/template_provider.dart';
import '../providers/theme_provider.dart';
import '../services/about_info.dart'; // Import AboutInfo
import '../services/auto_update_manager.dart'; // Import auto update manager
import '../services/enhanced_update_service.dart'; // Use enhanced service
import '../services/settings_service.dart';
import '../utils/app_fonts.dart'; // Import app fonts helper
import '../utils/responsive_layout.dart';
import '../utils/text_style_helper.dart';
import '../widgets/shared/custom_sliver_app_bar.dart'; // Import CustomSliverAppBar
import '../widgets/shared/app_loading_indicator.dart';
import '../widgets/shared/responsive_action.dart';
import '../widgets/programming_language_icon.dart';
import 'licenses_screen.dart'; // Third-party licenses screen
import 'template_edit_screen.dart';
import 'package:m3e_collection/m3e_collection.dart';
import 'tex_test_screen.dart'; // TeX表示テスト画面をインポート

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key, this.aboutInfoLoader});

  final Future<Map<String, dynamic>> Function()? aboutInfoLoader;

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String _currentVersion = "読み込み中...";
  bool _isLoadingUpdate = false;
  String _updateCheckResult = "";
  final EnhancedUpdateService _updateService = EnhancedUpdateService();
  final AutoUpdateManager _autoUpdateManager = AutoUpdateManager();
  bool _autoUpdateCheckEnabled = true;
  bool _showUpdateDialog = true; // アップデート通知の表示設定
  Map<String, dynamic>? _aboutInfo;
  bool _developerModeEnabled = false;
  int _buildNumberTapCount = 0;
  // AtCoder ユーザー名設定
  final TextEditingController _atcoderUsernameController =
      TextEditingController();
  String _savedAtCoderUsername = '';
  bool _isSavingAtCoderUsername = false;
  @override
  void initState() {
    super.initState();
    _loadCurrentVersion();
    _loadAutoUpdatePreference(); // Load preference
    _loadShowUpdateDialogPreference(); // Load show update dialog preference
    _loadAboutInfo(); // Load about info
    _loadAtCoderUsername(); // Load AtCoder username
    _loadDeveloperMode();
  }

  Future<void> _loadDeveloperMode() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      _developerModeEnabled = prefs.getBool('developer_mode_enabled') ?? false;
    });
  }

  Future<void> _handleBuildNumberTap() async {
    if (_developerModeEnabled) return;
    _buildNumberTapCount++;
    final remaining = 5 - _buildNumberTapCount;
    if (_buildNumberTapCount >= 5) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('developer_mode_enabled', true);
      if (!mounted) return;
      setState(() {
        _developerModeEnabled = true;
        _buildNumberTapCount = 0;
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('開発者モードを有効にしました')));
    } else if (remaining <= 3 && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('開発者モードまであと$remaining回'),
          duration: const Duration(milliseconds: 700),
        ),
      );
    }
  }

  Future<void> _loadCurrentVersion() async {
    try {
      String version = await _updateService.getCurrentAppVersion();
      if (mounted) {
        setState(() {
          _currentVersion = version;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _currentVersion = "取得エラー";
        });
      }
      debugPrint('Failed to load current version: $e');
    }
  }

  // AtCoder ユーザー名の読み込み/保存
  Future<void> _loadAtCoderUsername() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final saved = prefs.getString('atcoder_username') ?? '';
      if (mounted) {
        setState(() {
          _savedAtCoderUsername = saved;
          _atcoderUsernameController.text = saved;
        });
      }
    } catch (e) {
      // ignore
    }
  }

  Future<void> _saveAtCoderUsername() async {
    final username = _atcoderUsernameController.text.trim();
    if (_isSavingAtCoderUsername || username == _savedAtCoderUsername) return;

    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    setState(() {
      _isSavingAtCoderUsername = true;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('atcoder_username', username);
      // If theme uses AtCoder accent, refresh it
      try {
        if (themeProvider.useAtcoderRatingColor) {
          await themeProvider.refreshAtcoderAccentColor();
        }
      } catch (_) {
        // ignore UI refresh errors
      }
      if (!mounted) return;
      setState(() {
        _savedAtCoderUsername = username;
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('AtCoderユーザー名を保存しました')));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('保存に失敗しました: $e')));
    } finally {
      if (mounted) {
        setState(() {
          _isSavingAtCoderUsername = false;
        });
      }
    }
  }

  // Method to load auto update preference
  Future<void> _loadAutoUpdatePreference() async {
    bool enabled = await _autoUpdateManager.isAutoUpdateEnabled();
    if (mounted) {
      setState(() {
        _autoUpdateCheckEnabled = enabled;
      });
    }
  }

  // Method to save auto update preference
  Future<void> _setAutoUpdatePreference(bool value) async {
    await _autoUpdateManager.setAutoUpdateEnabled(value);
    if (mounted) {
      setState(() {
        _autoUpdateCheckEnabled = value;
      });
    }
  }

  // Method to load show update dialog preference
  Future<void> _loadShowUpdateDialogPreference() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedShowUpdateDialog = prefs.getBool('show_update_dialog');
      if (mounted) {
        setState(() {
          _showUpdateDialog = savedShowUpdateDialog ?? true; // デフォルトはtrue
        });
      }
    } catch (e) {
      debugPrint('Failed to load show update dialog preference: $e');
    }
  }

  // Method to set show update dialog preference
  Future<void> _setShowUpdateDialog(bool value) async {
    // SharedPreferencesを使って設定を保存
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('show_update_dialog', value);
      if (mounted) {
        setState(() {
          _showUpdateDialog = value;
        });
      }
    } catch (e) {
      debugPrint('Failed to save show update dialog preference: $e');
    }
  }

  Future<void> _loadAboutInfo() async {
    try {
      final info =
          await (widget.aboutInfoLoader?.call() ?? AboutInfo.getInfo());
      if (mounted) {
        setState(() {
          _aboutInfo = info;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _aboutInfo = {'error': 'アプリ情報の取得に失敗しました'};
        });
      }
    }
  }

  Future<void> _checkForUpdates() async {
    if (!mounted) return;
    setState(() {
      _isLoadingUpdate = true;
      _updateCheckResult = "";
    });

    try {
      EnhancedAppUpdateInfo? releaseInfo = await _autoUpdateManager
          .checkForUpdatesManually();
      if (!mounted) return;

      if (releaseInfo != null) {
        setState(() {
          _updateCheckResult = "新しいバージョンがあります: ${releaseInfo.version}";
        });
        _showUpdateDialogMethod(releaseInfo);
      } else {
        setState(() {
          _updateCheckResult = "お使いのバージョンは最新です。";
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _updateCheckResult = "更新チェック中にエラーが発生しました: $e";
        });
      }
      debugPrint('Error checking for updates: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingUpdate = false;
        });
      }
    }
  }

  void _showUpdateDialogMethod(EnhancedAppUpdateInfo releaseInfo) {
    if (!mounted) return;
    _autoUpdateManager.showManualUpdateDialog(context, releaseInfo);
  }

  @override
  void dispose() {
    _atcoderUsernameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final horizontalInset = ResponsiveLayout.horizontalPadding(
      context,
      minimum: 8,
    );

    return CustomScrollView(
      slivers: [
        // カスタムSliverAppBar
        CustomSliverAppBar(
          isMainView: true,
          title: Text(
            '設定',
            style: AppFonts.notoSansJp(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).textTheme.titleLarge!.color,
            ),
          ),
        ),

        // 設定項目のリスト
        SliverPadding(
          padding: EdgeInsets.symmetric(horizontal: horizontalInset),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              const SizedBox(height: 8),
              // AtCoder 設定セクション（最上部）
              _buildAtcoderSection(),
              const SizedBox(height: 12),

              // テーマ設定セクション
              _buildThemeSection(),
              const SizedBox(height: 12),

              // エディタ設定セクション
              _buildEditorSection(),
              const SizedBox(height: 12),

              // テンプレート設定セクション
              _buildTemplateSection(),
              const SizedBox(height: 12),

              // 更新設定セクション
              _buildUpdateSection(),
              const SizedBox(height: 12),

              // バックアップ設定セクション
              _buildExportSection(),
              const SizedBox(height: 12),

              // アプリについてセクション
              _buildAboutSection(),
              SizedBox(
                height: ResponsiveLayout.bottomNavigationClearance(
                  context,
                  spacing: 32,
                ),
              ),
            ]),
          ),
        ),
      ],
    );
  } // 新しいセクションウィジェット群

  InputDecoration _settingsInputDecoration({
    required String labelText,
    String? hintText,
    required IconData prefixIcon,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: BorderSide(color: colorScheme.outlineVariant),
    );

    return InputDecoration(
      labelText: labelText,
      hintText: hintText,
      prefixIcon: Icon(prefixIcon),
      filled: true,
      fillColor: colorScheme.surfaceContainerHighest.withValues(alpha: 0.35),
      border: border,
      enabledBorder: border,
      focusedBorder: border.copyWith(
        borderSide: BorderSide(color: colorScheme.primary, width: 1.6),
      ),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 12.0,
        vertical: 12.0,
      ),
    );
  }

  Widget _buildAtcoderSection() {
    return _SettingsSection(
      title: 'AtCoder設定',
      icon: Icons.person_outline,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20.0, 12.0, 20.0, 0.0),
          child: TextField(
            controller: _atcoderUsernameController,
            decoration: _settingsInputDecoration(
              labelText: 'AtCoderユーザー名',
              hintText: '例: tourist',
              prefixIcon: Icons.person_outline,
            ),
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => _saveAtCoderUsername(),
          ),
        ),
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: ResponsiveAction(
            maxWidth: 200,
            child: ValueListenableBuilder<TextEditingValue>(
              valueListenable: _atcoderUsernameController,
              builder: (context, value, child) {
                final hasChanges = value.text.trim() != _savedAtCoderUsername;
                final isSaved = !hasChanges && !_isSavingAtCoderUsername;
                return ButtonM3E(
                  onPressed: hasChanges && !_isSavingAtCoderUsername
                      ? _saveAtCoderUsername
                      : null,
                  icon: _isSavingAtCoderUsername
                      ? const AppLoadingIndicator(
                          size: 18,
                          semanticsLabel: 'AtCoderユーザー名を保存中',
                        )
                      : Icon(
                          isSaved
                              ? Icons.check_circle_outline
                              : Icons.save_outlined,
                        ),
                  label: Text(
                    _isSavingAtCoderUsername
                        ? '保存中'
                        : isSaved
                        ? '保存済み'
                        : '保存',
                  ),
                  style: isSaved ? ButtonM3EStyle.tonal : ButtonM3EStyle.filled,
                );
              },
            ),
          ),
        ),
        const Padding(
          padding: EdgeInsets.fromLTRB(20.0, 8.0, 20.0, 12.0),
          child: Text('このユーザー名はレーティング取得やおすすめ問題などで使用されます。'),
        ),
      ],
    );
  }

  Widget _buildThemeSection() {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return _SettingsSection(
          title: 'テーマ設定',
          icon: Icons.palette,
          children: [
            ...ThemeModeOption.values.map(
              (mode) => _HapticRadioListTile<ThemeModeOption>(
                title: mode.label,
                value: mode,
                groupValue: themeProvider.themeMode,
                onChanged: (value) {
                  if (value != null) {
                    themeProvider.setThemeMode(value);
                  }
                },
                secondary: _getThemeIcon(mode),
              ),
            ),
            _HapticSwitchListTile(
              title: 'Material You',
              subtitle: 'よりデバイスに近い体験が楽しめます',
              value: themeProvider.useMaterialYou,
              onChanged: themeProvider.setUseMaterialYou,
              icon: Icons.color_lens_outlined,
            ),
            _HapticSwitchListTile(
              title: 'AtCoderの色をテーマに使う',
              subtitle: '保存したユーザーのレート色をアクセントに適用します',
              value: themeProvider.useAtcoderRatingColor,
              onChanged: (v) async {
                await themeProvider.setUseAtcoderRatingColor(v);
                if (v) {
                  await themeProvider.refreshAtcoderAccentColor();
                }
              },
              icon: Icons.emoji_events_outlined,
            ),
            const Divider(),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 20.0,
                vertical: 16.0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'ナビゲーションバーの透明度',
                    style: AppFonts.notoSansJp(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      '${(themeProvider.navBarOpacity * 100).round()}%',
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  SliderM3E(
                    min: 0.0,
                    max: 1.0,
                    divisions: 20,
                    label: '${(themeProvider.navBarOpacity * 100).round()}%',
                    value: themeProvider.navBarOpacity,
                    onChanged: (value) {
                      HapticFeedback.lightImpact();
                      themeProvider.setNavBarOpacity(value);
                    },
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '透明',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                      Text(
                        '不透明',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildEditorSection() {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return _SettingsSection(
          title: 'エディタ設定',
          icon: Icons.code,
          children: [
            // Editor type selection
            Padding(
              padding: const EdgeInsets.fromLTRB(20.0, 16.0, 20.0, 8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'エディタタイプ',
                    style: AppFonts.notoSansJp(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
            ),
            ...EditorType.values.map(
              (type) => _HapticRadioListTile<EditorType>(
                title: type.label,
                subtitle: type == EditorType.monaco
                    ? 'VS Codeと同じエディタです。キーボードが出てこないなどの問題が発生することがあります。'
                    : null,
                value: type,
                groupValue: themeProvider.editorType,
                onChanged: (value) {
                  if (value != null) {
                    themeProvider.setEditorType(value);
                  }
                },
                secondary: _getEditorTypeIcon(type),
              ),
            ),
            const Divider(),
            // Font Family Selector
            Padding(
              padding: const EdgeInsets.fromLTRB(20.0, 16.0, 20.0, 8.0),
              child: DropdownButtonFormField<String>(
                initialValue: themeProvider.codeFontFamily,
                isExpanded: true,
                borderRadius: BorderRadius.circular(8),
                decoration: _settingsInputDecoration(
                  labelText: 'コードブロックのフォント',
                  prefixIcon: Icons.font_download_outlined,
                ),
                items: themeProvider.availableCodeFontFamilies.map((
                  String fontFamily,
                ) {
                  return DropdownMenuItem<String>(
                    value: fontFamily,
                    child: Text(
                      fontFamily,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: getMonospaceTextStyle(fontFamily),
                    ),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  if (newValue != null) {
                    HapticFeedback.lightImpact();
                    themeProvider.setCodeFontFamily(newValue);
                  }
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _getEditorTypeIcon(EditorType type) {
    switch (type) {
      case EditorType.classic:
        return const Icon(Icons.text_fields);
      case EditorType.monaco:
        return const Icon(Icons.integration_instructions);
    }
  }

  Widget _buildTemplateSection() {
    return Consumer<TemplateProvider>(
      builder: (context, templateProvider, child) {
        return _SettingsSection(
          title: 'テンプレート設定',
          icon: Icons.code,
          children: templateProvider.supportedLanguages.map((language) {
            return _SettingsActionListTile(
              title: language,
              leading: ProgrammingLanguageIcon(language: language),
              trailing: Icon(
                Icons.edit_outlined,
                color: Theme.of(context).colorScheme.primary,
              ),
              onTap: () {
                HapticFeedback.lightImpact();
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        TemplateEditScreen(language: language),
                  ),
                );
              },
            );
          }).toList(),
        );
      },
    );
  }

  Widget _buildUpdateSection() {
    final colorScheme = Theme.of(context).colorScheme;

    return _SettingsSection(
      title: '更新設定',
      icon: Icons.system_update_alt,
      children: [
        if (BuildConfig.enableSelfUpdate) ...[
          _HapticSwitchListTile(
            title: 'アプリ起動時に自動で更新を確認',
            value: _autoUpdateCheckEnabled,
            onChanged: _setAutoUpdatePreference,
            icon: Icons.sync_outlined,
          ),
          _HapticSwitchListTile(
            title: 'アップデート通知を表示',
            subtitle: '新しいバージョンが利用可能な時に通知を表示',
            value: _showUpdateDialog,
            onChanged: _setShowUpdateDialog,
            icon: Icons.notifications_outlined,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 20.0,
              vertical: 16.0,
            ),
            child: Column(
              children: [
                ResponsiveAction(
                  child: ButtonM3E(
                    onPressed: _isLoadingUpdate ? null : _checkForUpdates,
                    icon: const Icon(Icons.update),
                    label: const Text('更新を確認'),
                    style: ButtonM3EStyle.filled,
                  ),
                ),
                if (_isLoadingUpdate) ...[
                  const SizedBox(height: 16),
                  const AppLoadingIndicator(semanticsLabel: 'アップデート情報を読み込み中'),
                ],
                if (_updateCheckResult.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Text(
                    _updateCheckResult,
                    textAlign: TextAlign.center,
                    style: AppFonts.notoSansJp(fontSize: 14),
                  ),
                ],
              ],
            ),
          ),
        ] else ...[
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
            child: Container(
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
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.info_outline,
                    size: 20,
                    color: colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'このビルドでは自己アップデート機能は無効化されています。最新バージョンは公式GitHubリリースまたはF-Droidリポジトリ経由で入手してください。',
                      style: AppFonts.notoSansJp(
                        fontSize: 14,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildExportSection() {
    return _SettingsSection(
      title: 'バックアップ',
      icon: Icons.cloud_sync_outlined,
      children: [
        _SettingsActionListTile(
          title: '設定をコピー',
          subtitle: 'クリップボードにバックアップ',
          icon: Icons.copy_all_outlined,
          onTap: () async {
            HapticFeedback.lightImpact();
            await _exportSettingsToClipboard();
          },
        ),
        _SettingsActionListTile(
          title: 'コピーした設定を復元',
          subtitle: 'クリップボードから読み込み',
          icon: Icons.paste_outlined,
          onTap: () async {
            HapticFeedback.lightImpact();
            await _importSettingsFromClipboard();
          },
        ),
        const Divider(),
        _SettingsActionListTile(
          title: '設定ファイルを共有',
          subtitle: 'ファイルとして保存または送信',
          icon: Icons.ios_share_outlined,
          onTap: () async {
            HapticFeedback.lightImpact();
            await _exportSettings();
          },
        ),
        _SettingsActionListTile(
          title: '設定ファイルから復元',
          subtitle: '保存したファイルを読み込み',
          icon: Icons.file_open_outlined,
          onTap: () async {
            HapticFeedback.lightImpact();
            await _importSettings();
          },
        ),
      ],
    );
  }

  Widget _buildAboutSection() {
    return _SettingsSection(
      title: 'アプリについて',
      icon: Icons.info_outline,
      children: [
        _CopyableListTile(
          title: 'バージョン',
          subtitle: _currentVersion,
          icon: Icons.tag,
          onCopy: _copyAllAppInfo,
        ),
        // 開発者セクション（ソーシャルメディアリンク付き）
        _buildDeveloperSection(),
        const Divider(),
        _SettingsActionListTile(
          icon: Icons.rule_folder_outlined,
          title: 'ライセンス',
          subtitle: '直接 / 全依存 / 標準 Flutter',
          trailing: const Icon(Icons.chevron_right),
          onTap: () {
            Navigator.of(
              context,
            ).push(MaterialPageRoute(builder: (_) => const LicensesScreen()));
          },
        ),
        _SettingsActionListTile(
          icon: Icons.privacy_tip_outlined,
          title: 'プライバシーポリシー',
          trailing: const Icon(Icons.open_in_new, size: 20),
          onTap: () {
            launchUrl(
              Uri.parse(
                'https://github.com/Shojin-App/shojin_app/blob/main/PRIVACY_POLICY.md',
              ),
            );
          },
        ),
        _SettingsActionListTile(
          icon: Icons.article_outlined,
          title: '利用規約',
          trailing: const Icon(Icons.open_in_new, size: 20),
          onTap: () {
            launchUrl(
              Uri.parse(
                'https://github.com/Shojin-App/shojin_app/blob/main/TERMS_OF_USE.md',
              ),
            );
          },
        ),
        if (_developerModeEnabled) ...[
          const Divider(),
          const _SettingsActionListTile(
            icon: Icons.developer_mode,
            title: '開発者向け機能',
            subtitle: '内部機能の動作確認',
          ),
          _SettingsActionListTile(
            icon: Icons.functions,
            title: 'TeX表示テスト',
            subtitle: 'LaTeX数式レンダリングの動作確認',
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const TexTestScreen()),
              );
            },
          ),
        ],
        if (_aboutInfo != null) ...[
          const Divider(),
          if (_aboutInfo!['error'] != null)
            _SettingsActionListTile(
              icon: Icons.error_outline,
              title: 'エラー',
              subtitle: _aboutInfo!['error'],
            )
          else
            _buildAboutDetailsExpansion(),
        ] else
          const _SettingsActionListTile(
            title: '情報の読み込み中...',
            subtitle: '端末とアプリの情報を確認しています',
            leading: SizedBox(
              width: 24,
              height: 24,
              child: LoadingIndicatorM3E(),
            ),
          ),
      ],
    );
  }

  List<Widget> _buildAboutDetails() {
    return [
      _CopyableListTile(
        title: 'アプリ名',
        subtitle: _aboutInfo!['appName'] ?? '不明',
        icon: Icons.apps,
        onCopy: _copyAllAppInfo,
      ),
      _CopyableListTile(
        title: 'パッケージ名',
        subtitle: _aboutInfo!['packageName'] ?? '不明',
        icon: Icons.inventory,
        onCopy: _copyAllAppInfo,
      ),
      _SettingsActionListTile(
        icon: Icons.build,
        title: 'ビルド番号',
        subtitle: _aboutInfo!['buildNumber'] ?? '不明',
        onTap: _handleBuildNumberTap,
        onLongPress: () => _copyAllAppInfo(context),
      ),
      _CopyableListTile(
        title: 'プラットフォーム',
        subtitle: _aboutInfo!['platform'] ?? '不明',
        icon: Icons.computer,
        onCopy: _copyAllAppInfo,
      ),
      if (_aboutInfo!['model'] != null)
        _CopyableListTile(
          title: 'デバイスモデル',
          subtitle: _aboutInfo!['model'],
          icon: Icons.phone_android,
          onCopy: _copyAllAppInfo,
        ),
      if (_aboutInfo!['androidVersion'] != null)
        _CopyableListTile(
          title: 'Androidバージョン',
          subtitle: _aboutInfo!['androidVersion'],
          icon: Icons.android,
          onCopy: _copyAllAppInfo,
        ),
      if (_aboutInfo!['supportedArch'] != null)
        _CopyableListTile(
          title: 'サポートアーキテクチャ',
          subtitle: (_aboutInfo!['supportedArch'] as List).join(', '),
          icon: Icons.architecture,
          onCopy: _copyAllAppInfo,
        ),
      _CopyableListTile(
        title: 'ビルドタイプ',
        subtitle: _aboutInfo!['flavor'] ?? '不明',
        icon: Icons.settings,
        onCopy: _copyAllAppInfo,
      ),
    ];
  }

  Widget _buildAboutDetailsExpansion() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return ExpansionTile(
      tilePadding: const EdgeInsets.symmetric(horizontal: 20),
      shape: const Border(),
      collapsedShape: const Border(),
      iconColor: colorScheme.onSurfaceVariant,
      collapsedIconColor: colorScheme.onSurfaceVariant,
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.55),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(Icons.data_object, color: colorScheme.onSurfaceVariant),
      ),
      title: Text(
        '詳細情報',
        style: theme.textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: Text(
        '端末・パッケージ・ビルド情報',
        style: theme.textTheme.bodySmall?.copyWith(
          color: colorScheme.onSurfaceVariant,
        ),
      ),
      children: _buildAboutDetails(),
    );
  }

  Widget _buildDeveloperSection() {
    final colorScheme = Theme.of(context).colorScheme;

    return ExpansionTile(
      title: Text(
        '開発者',
        style: AppFonts.notoSansJp(fontSize: 16, fontWeight: FontWeight.w500),
      ),
      subtitle: Text(
        '〒«ゆうびんきょく»',
        style: AppFonts.notoSansJp(
          fontSize: 14,
          color: colorScheme.onSurfaceVariant,
        ),
      ),
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.55),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: Icon(Icons.code, color: colorScheme.onSurfaceVariant),
        ),
      ),
      iconColor: colorScheme.onSurfaceVariant,
      collapsedIconColor: colorScheme.onSurfaceVariant,
      tilePadding: const EdgeInsets.symmetric(horizontal: 20),
      shape: const Border(), // 白い線を非表示にする
      collapsedShape: const Border(), // 折りたたみ時の白い線も非表示にする
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Column(
            children: [
              _SocialMediaItem(
                icon: Icons.language,
                title: 'Website',
                subtitle: 'yuubinnkyoku.github.io',
                url: 'https://yuubinnkyoku.github.io/',
              ),
              _SocialMediaItem(
                icon: SvgPicture.asset(
                  'assets/icon/twitter_logo.svg',
                  width: 24,
                  height: 24,
                  colorFilter: ColorFilter.mode(
                    Theme.of(context).colorScheme.primary,
                    BlendMode.srcIn,
                  ),
                ),
                title: 'Twitter',
                subtitle: '@yuubinnkyoku_mk',
                url: 'https://twitter.com/yuubinnkyoku_mk',
              ),
              _SocialMediaItem(
                icon: SvgPicture.asset(
                  'assets/icon/youtube_logo.svg',
                  width: 24,
                  height: 24,
                  colorFilter: ColorFilter.mode(
                    Theme.of(context).colorScheme.primary,
                    BlendMode.srcIn,
                  ),
                ),
                title: 'YouTube',
                subtitle: '@yuubinnkyoku',
                url: 'https://www.youtube.com/@yuubinnkyoku',
              ),
              _SocialMediaItem(
                icon: SvgPicture.asset(
                  'assets/icon/github_logo.svg',
                  width: 24,
                  height: 24,
                  colorFilter: ColorFilter.mode(
                    Theme.of(context).colorScheme.primary,
                    BlendMode.srcIn,
                  ),
                ),
                title: 'GitHub',
                subtitle: 'yuubinnkyoku',
                url: 'https://github.com/yuubinnkyoku',
              ),
            ],
          ),
        ),
      ],
    );
  }

  // テーマモードに対応するアイコンを返す
  Widget _getThemeIcon(ThemeModeOption mode) {
    switch (mode) {
      case ThemeModeOption.system:
        return const Icon(Icons.settings_suggest);
      case ThemeModeOption.light:
        return const Icon(Icons.light_mode);
      case ThemeModeOption.dark:
        return const Icon(Icons.dark_mode);
      case ThemeModeOption.pureBlack:
        return const Icon(Icons.nights_stay);
    }
  }

  // エクスポート/インポートメソッド群
  Future<void> _exportSettings() async {
    final settingsService = SettingsService(context);
    await settingsService.exportSettings();
  }

  Future<void> _importSettings() async {
    final settingsService = SettingsService(context);
    await settingsService.importSettings();
  }

  Future<void> _exportSettingsToClipboard() async {
    final settingsService = SettingsService(context);
    await settingsService.exportSettingsToClipboard();
  }

  Future<void> _importSettingsFromClipboard() async {
    final settingsService = SettingsService(context);
    await settingsService.importSettingsFromClipboard();
  }

  String _getAllAppInfo() {
    List<String> infoLines = [];

    // バージョン情報
    infoLines.add('バージョン: $_currentVersion');

    // アプリについての詳細情報
    if (_aboutInfo != null && _aboutInfo!['error'] == null) {
      infoLines.add('アプリ名: ${_aboutInfo!['appName'] ?? '不明'}');
      infoLines.add('パッケージ名: ${_aboutInfo!['packageName'] ?? '不明'}');
      infoLines.add('ビルド番号: ${_aboutInfo!['buildNumber'] ?? '不明'}');
      infoLines.add('プラットフォーム: ${_aboutInfo!['platform'] ?? '不明'}');

      if (_aboutInfo!['model'] != null) {
        infoLines.add('デバイスモデル: ${_aboutInfo!['model']}');
      }

      if (_aboutInfo!['androidVersion'] != null) {
        infoLines.add('Androidバージョン: ${_aboutInfo!['androidVersion']}');
      }

      if (_aboutInfo!['supportedArch'] != null) {
        infoLines.add(
          'サポートアーキテクチャ: ${(_aboutInfo!['supportedArch'] as List).join(', ')}',
        );
      }

      infoLines.add('ビルドタイプ: ${_aboutInfo!['flavor'] ?? '不明'}');
    }

    return infoLines.join('\n');
  }

  void _copyAllAppInfo(BuildContext context) {
    String allInfo = _getAllAppInfo();
    Clipboard.setData(ClipboardData(text: allInfo));
    HapticFeedback.lightImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('アプリ情報をすべてコピーしました'),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}

// 設定セクションのベースウィジェット
class _SettingsSection extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<Widget> children;

  const _SettingsSection({
    required this.title,
    required this.icon,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Material(
      color: colorScheme.surfaceContainerLow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.0),
        side: BorderSide(
          // 暗色テーマでも枠線が本文より先に目立たない強さに留める。
          color: colorScheme.outlineVariant.withValues(alpha: 0.35),
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16.0, 12.0, 16.0, 8.0),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Icon(
                      icon,
                      size: 20,
                      color: colorScheme.onPrimaryContainer,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: AppFonts.notoSansJp(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: colorScheme.onSurface,
                    ),
                  ),
                ),
              ],
            ),
          ),
          ...children,
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

// ハプティックフィードバック付きスイッチListTile
class _HapticSwitchListTile extends StatelessWidget {
  final String title;
  final String? subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;
  final IconData icon;

  const _HapticSwitchListTile({
    required this.title,
    this.subtitle,
    required this.value,
    required this.onChanged,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return SwitchListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20.0),
      secondary: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: value
              ? colorScheme.primaryContainer
              : colorScheme.surfaceContainerHighest.withValues(alpha: 0.55),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: Icon(
            icon,
            color: value
                ? colorScheme.onPrimaryContainer
                : colorScheme.onSurfaceVariant,
          ),
        ),
      ),
      title: Text(
        title,
        style: AppFonts.notoSansJp(
          fontSize: 16,
          fontWeight: value ? FontWeight.w600 : FontWeight.w400,
        ),
      ),
      subtitle: subtitle != null
          ? Text(
              subtitle!,
              style: AppFonts.notoSansJp(
                fontSize: 14,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            )
          : null,
      value: value,
      onChanged: (newValue) {
        HapticFeedback.lightImpact();
        onChanged(newValue);
      },
    );
  }
}

// ハプティックフィードバック付きRadioListTile
class _HapticRadioListTile<T> extends StatelessWidget {
  final String title;
  final String? subtitle;
  final T value;
  final T? groupValue;
  final ValueChanged<T?> onChanged;
  final Widget secondary;

  const _HapticRadioListTile({
    required this.title,
    this.subtitle,
    required this.value,
    required this.groupValue,
    required this.onChanged,
    required this.secondary,
  });

  @override
  Widget build(BuildContext context) {
    final bool isSelected = value == groupValue;
    final colorScheme = Theme.of(context).colorScheme;

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20.0),
      tileColor: isSelected
          ? colorScheme.primaryContainer.withValues(alpha: 0.28)
          : null,
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: isSelected
              ? colorScheme.primaryContainer
              : colorScheme.surfaceContainerHighest.withValues(alpha: 0.55),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: IconTheme(
            data: IconThemeData(
              color: isSelected
                  ? colorScheme.onPrimaryContainer
                  : colorScheme.onSurfaceVariant,
            ),
            child: secondary,
          ),
        ),
      ),
      title: Text(
        title,
        style: AppFonts.notoSansJp(
          fontSize: 16,
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
        ),
      ),
      subtitle: subtitle != null
          ? Text(
              subtitle!,
              style: AppFonts.notoSansJp(
                fontSize: 12,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            )
          : null,
      trailing: Icon(
        isSelected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
        color: isSelected ? colorScheme.primary : colorScheme.onSurfaceVariant,
      ),
      onTap: () {
        HapticFeedback.lightImpact();
        onChanged(value);
      },
    );
  }
}

class _SettingsActionListTile extends StatelessWidget {
  final String title;
  final String? subtitle;
  final IconData? icon;
  final Widget? leading;
  final Widget? trailing;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  const _SettingsActionListTile({
    required this.title,
    this.subtitle,
    this.icon,
    this.leading,
    this.trailing,
    this.onTap,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final leadingChild =
        leading ?? Icon(icon, color: colorScheme.onSurfaceVariant);

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20.0),
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.55),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(child: leadingChild),
      ),
      title: Text(
        title,
        style: AppFonts.notoSansJp(fontSize: 16, fontWeight: FontWeight.w500),
      ),
      subtitle: subtitle != null
          ? Text(
              subtitle!,
              style: AppFonts.notoSansJp(
                fontSize: 14,
                color: colorScheme.onSurfaceVariant,
              ),
            )
          : null,
      trailing: trailing,
      onTap: onTap,
      onLongPress: onLongPress,
    );
  }
}

// コピー可能なListTile
class _CopyableListTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final void Function(BuildContext) onCopy;

  const _CopyableListTile({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onCopy,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    void copy() {
      HapticFeedback.lightImpact();
      onCopy(context);
    }

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20.0),
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.55),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(child: Icon(icon, color: colorScheme.onSurfaceVariant)),
      ),
      title: Text(
        title,
        style: AppFonts.notoSansJp(fontSize: 16, fontWeight: FontWeight.w400),
      ),
      subtitle: Text(
        subtitle,
        style: AppFonts.notoSansJp(
          fontSize: 14,
          color: colorScheme.onSurfaceVariant,
        ),
      ),
      trailing: IconButton(
        tooltip: '$titleをコピー',
        icon: const Icon(Icons.copy_outlined),
        onPressed: copy,
      ),
      onLongPress: copy,
      onTap: copy,
    );
  }
}

// ソーシャルメディアアイテム
class _SocialMediaItem extends StatelessWidget {
  final dynamic icon; // IconData or Widget
  final String title;
  final String subtitle;
  final String url;

  const _SocialMediaItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.url,
  });
  Future<void> _launchUrl(BuildContext context) async {
    try {
      final uri = Uri.parse(url);
      // より確実なURL起動方法を使用
      await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
        webViewConfiguration: const WebViewConfiguration(
          enableJavaScript: true,
          enableDomStorage: true,
        ),
      );
      HapticFeedback.lightImpact();
    } catch (e) {
      // canLaunchUrlをチェックしないで直接起動を試行
      // 失敗した場合のフォールバック処理
      try {
        await launchUrl(Uri.parse(url), mode: LaunchMode.platformDefault);
        HapticFeedback.lightImpact();
      } catch (fallbackError) {
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('URLを開けませんでした: $url'),
            behavior: SnackBarBehavior.floating,
            action: SnackBarAction(
              label: 'コピー',
              onPressed: () {
                Clipboard.setData(ClipboardData(text: url));
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('URLをクリップボードにコピーしました'),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16.0),
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.55),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: icon is IconData
              ? Icon(icon as IconData, color: colorScheme.onSurfaceVariant)
              : icon as Widget,
        ),
      ),
      title: Text(
        title,
        style: AppFonts.notoSansJp(fontSize: 16, fontWeight: FontWeight.w500),
      ),
      subtitle: Text(
        subtitle,
        style: AppFonts.notoSansJp(
          fontSize: 14,
          color: colorScheme.onSurfaceVariant,
        ),
      ),
      trailing: Icon(
        Icons.open_in_new,
        color: colorScheme.onSurfaceVariant,
        size: 20,
      ),
      onTap: () => _launchUrl(context),
    );
  }
}
