import 'dart:async';
import 'dart:developer' as developer;

import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart'; // 追加
import 'package:m3e_collection/m3e_collection.dart'; // Import m3e_collection
import 'package:provider/provider.dart';

import 'config/build_config.dart'; // Add build configuration
import 'l10n/app_localizations.dart'; // 追加 (生成されるファイル)
import 'providers/contest_provider.dart';
import 'providers/template_provider.dart';
import 'providers/theme_provider.dart';
import 'screens/browser_screen.dart'; // Import the new browser screen
import 'screens/editor_screen.dart';
import 'screens/home_screen_new.dart'; // Import new home screen
import 'screens/problem_detail_screen.dart';
import 'screens/settings_screen.dart';
import 'services/auto_update_manager.dart'; // Add auto update manager
import 'services/contest_reminder_service.dart';
import 'services/notification_service.dart'; // Import NotificationService
import 'utils/app_fonts.dart'; // Import app fonts helper
import 'utils/responsive_layout.dart';
import 'widgets/shared/app_bottom_navigation.dart';
import 'widgets/shared/custom_sliver_app_bar.dart';

void main() async {
  // Flutter Engineの初期化を保証
  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

  // F-Droid ビルド安全性アサート: 自己アップデートが無効であること
  assert(() {
    if (BuildConfig.isFdroidBuild && BuildConfig.enableSelfUpdate) {
      throw StateError(
        'FDROID_BUILD=true なのに enableSelfUpdate が true です。ビルドフラグ/defines を再確認してください。',
      );
    }
    return true;
  }());

  // Providerのインスタンスを作成
  final themeProvider = ThemeProvider();
  final templateProvider = TemplateProvider();
  final contestProvider = ContestProvider();

  // 永続設定や通知プラグインの応答が遅くても、最初のフレームは既定値で
  // 描画する。各Providerは読み込み完了時にnotifyListenersするため、UIは
  // 後から保存済み設定へ更新される。
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: themeProvider),
        ChangeNotifierProvider.value(value: templateProvider),
        ChangeNotifierProvider.value(value: contestProvider),
      ],
      child: const MyApp(),
    ),
  );
  unawaited(_initializeBackgroundServices());
  developer.log('App started successfully');
}

Future<void> _initializeBackgroundServices() async {
  // flutter_local_notificationsはWeb、Windows、Linux向けの初期化設定を
  // 持たない。未対応環境ではUI起動を妨げず、通知処理自体を実行しない。
  if (kIsWeb ||
      !const {
        TargetPlatform.android,
        TargetPlatform.iOS,
        TargetPlatform.macOS,
      }.contains(defaultTargetPlatform)) {
    return;
  }

  try {
    // 同じプラグインインスタンスを同期処理にも渡し、初期化済みであることを
    // 保ったまま保留通知の確認と再登録を行う。
    final notificationService = NotificationService();
    await notificationService.initialize();
    await ContestReminderService(
      notificationService: notificationService,
    ).synchronize();
  } catch (error, stackTrace) {
    developer.log(
      'Failed to initialize background services',
      name: 'AppStartup',
      error: error,
      stackTrace: stackTrace,
    );
  }
}

Color _onColorFor(Color color) {
  return color.computeLuminance() > 0.5 ? Colors.black : Colors.white;
}

SystemUiOverlayStyle appSystemUiOverlayStyle(Brightness brightness) {
  final iconBrightness = brightness == Brightness.dark
      ? Brightness.light
      : Brightness.dark;

  return SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: iconBrightness,
    statusBarBrightness: brightness,
    // Androidのジェスチャー／3ボタン領域にもアプリ側の半透明
    // ナビゲーション背景を連続させ、OSの追加scrimとの二重表示を防ぐ。
    systemNavigationBarColor: Colors.transparent,
    systemNavigationBarDividerColor: Colors.transparent,
    systemNavigationBarIconBrightness: iconBrightness,
    systemNavigationBarContrastEnforced: false,
  );
}

// デフォルトのカラースキーム（MaterialYou ON時）
const _defaultLightColorScheme = ColorScheme.light(
  primary: Colors.blue,
  onPrimary: Colors.white,
  secondary: Colors.blueAccent,
);

const _defaultDarkColorScheme = ColorScheme.dark(
  primary: Colors.blue,
  onPrimary: Colors.white,
  secondary: Colors.blueAccent,
);

// カスタムテーマ（MaterialYou OFF時）
const _lightPrimaryColor = Color(0xFF4C51C0);
const _darkPrimaryColor = Color(0xFFBFC1FF);

final _lightCustomTheme =
    ColorScheme.fromSeed(
      seedColor: Colors.purple,
      brightness: Brightness.light,
    ).copyWith(
      primary: _lightPrimaryColor,
      onPrimary: _onColorFor(_lightPrimaryColor),
    );

final _darkCustomTheme =
    ColorScheme.fromSeed(
      seedColor: Colors.purple,
      brightness: Brightness.dark,
    ).copyWith(
      primary: _darkPrimaryColor,
      onPrimary: _onColorFor(_darkPrimaryColor),
      surface: const Color(0xFF131316),
    );

// ピュアブラックモードのカラースキーム（カスタムテーマベース）
final _pureBlackColorScheme =
    ColorScheme.fromSeed(
      seedColor: Colors.purple,
      brightness: Brightness.dark,
    ).copyWith(
      primary: _darkPrimaryColor,
      onPrimary: _onColorFor(_darkPrimaryColor),
      surface: Colors.black,
      surfaceContainerHighest: Colors.black,
      onSurface: Colors.white,
      surfaceTint: Colors.transparent,
    );

/// Material Youのsurface階調は維持しつつ、アクセント用途の色ファミリーを
/// AtCoderレーティング色から再生成する。
///
/// primaryだけを置換するとsecondaryContainerが端末由来の色に残り、設定画面の
/// アイコンフィールドだけがAtCoderテーマから外れて見えるため、secondaryと
/// tertiaryも同じseedから導出する。primaryはレート色を忠実に表示する。
@visibleForTesting
ColorScheme applyAtCoderAccentColorScheme(ColorScheme base, Color seed) {
  final generated = ColorScheme.fromSeed(
    seedColor: seed,
    brightness: base.brightness,
  );
  final onPrimary = _onColorFor(seed);

  return base.copyWith(
    primary: seed,
    onPrimary: onPrimary,
    primaryContainer: seed,
    onPrimaryContainer: onPrimary,
    secondary: generated.secondary,
    onSecondary: generated.onSecondary,
    secondaryContainer: generated.secondaryContainer,
    onSecondaryContainer: generated.onSecondaryContainer,
    tertiary: generated.tertiary,
    onTertiary: generated.onTertiary,
    tertiaryContainer: generated.tertiaryContainer,
    onTertiaryContainer: generated.onTertiaryContainer,
    surfaceTint: Colors.transparent,
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // テーマプロバイダーの状態を監視
    final themeProvider = Provider.of<ThemeProvider>(context);

    return DynamicColorBuilder(
      builder: (ColorScheme? lightDynamic, ColorScheme? darkDynamic) {
        // Material You / Custom theme 基本スキーム決定
        ColorScheme lightColorScheme;
        ColorScheme darkColorScheme;
        if (themeProvider.useMaterialYou) {
          lightColorScheme = lightDynamic ?? _defaultLightColorScheme;
          darkColorScheme = themeProvider.isPureBlack
              ? _pureBlackColorScheme
              : (darkDynamic ?? _defaultDarkColorScheme);
        } else {
          lightColorScheme = _lightCustomTheme;
          darkColorScheme = themeProvider.isPureBlack
              ? _pureBlackColorScheme
              : _darkCustomTheme;
        }

        // AtCoderレーティング色をそのままテーマの主色に適用（ハーモナイズなしで忠実に）
        if (themeProvider.useAtcoderRatingColor &&
            themeProvider.atcoderAccentColor != null) {
          final seed = themeProvider.atcoderAccentColor!;
          lightColorScheme = applyAtCoderAccentColorScheme(
            lightColorScheme,
            seed,
          );

          final baseDark = darkColorScheme;
          final darkAdjusted = applyAtCoderAccentColorScheme(baseDark, seed);
          darkColorScheme = themeProvider.isPureBlack
              ? darkAdjusted.copyWith(
                  surface: Colors.black,
                  surfaceContainerHighest: Colors.black,
                  onSurface: Colors.white,
                  surfaceTint: Colors.transparent,
                )
              : darkAdjusted;
        }

        // Noto Sans JPフォントをテキストテーマに適用（F-Droid対応）
        final textTheme = TextTheme(
          displayLarge: AppFonts.notoSansJp(
            fontSize: 32,
            fontWeight: FontWeight.bold,
          ),
          displayMedium: AppFonts.notoSansJp(
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
          displaySmall: AppFonts.notoSansJp(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
          headlineLarge: AppFonts.notoSansJp(
            fontSize: 22,
            fontWeight: FontWeight.w600,
          ),
          headlineMedium: AppFonts.notoSansJp(
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
          headlineSmall: AppFonts.notoSansJp(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
          titleLarge: AppFonts.notoSansJp(
            fontSize: 18,
            fontWeight: FontWeight.w500,
          ),
          titleMedium: AppFonts.notoSansJp(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
          titleSmall: AppFonts.notoSansJp(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
          bodyLarge: AppFonts.notoSansJp(fontSize: 16),
          bodyMedium: AppFonts.notoSansJp(fontSize: 14),
          bodySmall: AppFonts.notoSansJp(fontSize: 12),
          labelLarge: AppFonts.notoSansJp(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
          labelMedium: AppFonts.notoSansJp(
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
          labelSmall: AppFonts.notoSansJp(
            fontSize: 11,
            fontWeight: FontWeight.w500,
          ),
        );

        return MaterialApp(
          title: 'Shojin',
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: AppLocalizations.supportedLocales,
          locale: const Locale('ja'),
          onGenerateTitle: (BuildContext context) =>
              AppLocalizations.of(context)!.appTitle, // 修正
          theme: withM3ETheme(
            ThemeData(
              colorScheme: lightColorScheme,
              useMaterial3: true,
              appBarTheme: const AppBarTheme(centerTitle: true, elevation: 2),
              cardTheme: CardThemeData(
                elevation: 2,
                margin: const EdgeInsets.all(8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
                // MaterialYou使用時のコントラスト改善
                surfaceTintColor: themeProvider.useMaterialYou
                    ? lightColorScheme.primary.withValues(alpha: 0.08)
                    : null,
              ),
              navigationBarTheme: NavigationBarThemeData(
                backgroundColor: Colors.transparent,
                surfaceTintColor: Colors.transparent,
                elevation: 0,
                indicatorColor: lightColorScheme.primary.withValues(
                  alpha: 0.20,
                ),
                iconTheme: WidgetStateProperty.resolveWith((states) {
                  final color = states.contains(WidgetState.selected)
                      ? lightColorScheme.primary
                      : lightColorScheme.onSurfaceVariant;
                  return IconThemeData(color: color);
                }),
                labelTextStyle: WidgetStateProperty.resolveWith((states) {
                  final color = states.contains(WidgetState.selected)
                      ? lightColorScheme.primary
                      : lightColorScheme.onSurfaceVariant;
                  return TextStyle(color: color);
                }),
              ),
              tabBarTheme: TabBarThemeData(
                indicator: BoxDecoration(
                  color: lightColorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                indicatorSize: TabBarIndicatorSize.tab,
                dividerColor: Colors.transparent,
                labelColor: lightColorScheme.onPrimaryContainer,
                unselectedLabelColor: lightColorScheme.onSurfaceVariant,
                labelStyle: textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              menuTheme: MenuThemeData(
                style: MenuStyle(
                  shape: WidgetStatePropertyAll(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
              popupMenuTheme: PopupMenuThemeData(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              dropdownMenuTheme: DropdownMenuThemeData(
                menuStyle: MenuStyle(
                  shape: WidgetStatePropertyAll(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
              dialogTheme: DialogThemeData(
                elevation: 3,
                backgroundColor: lightColorScheme.surfaceContainerHigh,
                surfaceTintColor: Colors.transparent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              snackBarTheme: SnackBarThemeData(
                behavior: SnackBarBehavior.floating,
                elevation: 3,
                backgroundColor: lightColorScheme.inverseSurface,
                actionTextColor: lightColorScheme.inversePrimary,
                contentTextStyle: textTheme.bodyMedium?.copyWith(
                  color: lightColorScheme.onInverseSurface,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              elevatedButtonTheme: ElevatedButtonThemeData(
                style: ElevatedButton.styleFrom(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24.0),
                  ),
                ),
              ),
              textTheme: textTheme,
              fontFamily: AppFonts.notoSansJpFontFamily,
            ),
          ),
          darkTheme: withM3ETheme(
            ThemeData(
              colorScheme: darkColorScheme,
              useMaterial3: true,
              appBarTheme: AppBarTheme(
                centerTitle: true,
                elevation: 2,
                backgroundColor: themeProvider.isPureBlack
                    ? Colors.black
                    : null,
              ),
              navigationBarTheme: NavigationBarThemeData(
                backgroundColor: Colors.transparent,
                surfaceTintColor: Colors.transparent,
                elevation: 0,
                indicatorColor: darkColorScheme.primary.withValues(alpha: 0.20),
                iconTheme: WidgetStateProperty.resolveWith((states) {
                  final color = states.contains(WidgetState.selected)
                      ? darkColorScheme.primary
                      : darkColorScheme.onSurfaceVariant;
                  return IconThemeData(color: color);
                }),
                labelTextStyle: WidgetStateProperty.resolveWith((states) {
                  final color = states.contains(WidgetState.selected)
                      ? darkColorScheme.primary
                      : darkColorScheme.onSurfaceVariant;
                  return TextStyle(color: color);
                }),
              ),
              tabBarTheme: TabBarThemeData(
                indicator: BoxDecoration(
                  color: darkColorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                indicatorSize: TabBarIndicatorSize.tab,
                dividerColor: Colors.transparent,
                labelColor: darkColorScheme.onPrimaryContainer,
                unselectedLabelColor: darkColorScheme.onSurfaceVariant,
                labelStyle: textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              menuTheme: MenuThemeData(
                style: MenuStyle(
                  shape: WidgetStatePropertyAll(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
              popupMenuTheme: PopupMenuThemeData(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              dropdownMenuTheme: DropdownMenuThemeData(
                menuStyle: MenuStyle(
                  shape: WidgetStatePropertyAll(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
              dialogTheme: DialogThemeData(
                elevation: 3,
                backgroundColor: darkColorScheme.surfaceContainerHigh,
                surfaceTintColor: Colors.transparent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              snackBarTheme: SnackBarThemeData(
                behavior: SnackBarBehavior.floating,
                elevation: 3,
                backgroundColor: darkColorScheme.inverseSurface,
                actionTextColor: darkColorScheme.inversePrimary,
                contentTextStyle: textTheme.bodyMedium?.copyWith(
                  color: darkColorScheme.onInverseSurface,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              cardTheme: CardThemeData(
                elevation: 2,
                margin: const EdgeInsets.all(8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
                color: themeProvider.isPureBlack
                    ? const Color(0xFF121212)
                    : null,
                // MaterialYou使用時のコントラスト改善
                surfaceTintColor: themeProvider.useMaterialYou
                    ? darkColorScheme.primary.withValues(alpha: 0.08)
                    : null,
              ),
              elevatedButtonTheme: ElevatedButtonThemeData(
                style: ElevatedButton.styleFrom(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24.0),
                  ),
                ),
              ),
              scaffoldBackgroundColor: themeProvider.isPureBlack
                  ? Colors.black
                  : null,
              textTheme: textTheme,
              fontFamily: AppFonts.notoSansJpFontFamily,
            ),
          ),
          themeMode: themeProvider.themeModeForFlutter,
          home: const MainScreen(),
        );
      },
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0; // Default to new Home tab
  String _currentProblemId = 'default_problem';
  String? _problemIdFromWebView;
  UpdateLifecycleManager? _updateLifecycleManager;

  @override
  void initState() {
    super.initState();

    // Initialize auto update manager for startup update checks
    if (AutoUpdateManager.kEnableSelfUpdate) {
      _updateLifecycleManager = UpdateLifecycleManager(context);
      _updateLifecycleManager!.startListening();
    }

    // Schedule initial update check after the first frame
    if (AutoUpdateManager.kEnableSelfUpdate) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final autoUpdateManager = AutoUpdateManager();
        autoUpdateManager.checkForUpdatesOnStartup(context);
      });
    }
  }

  @override
  void dispose() {
    _updateLifecycleManager?.stopListening();
    super.dispose();
  }

  // Callback for ProblemDetailScreen -> EditorScreen update
  void _updateProblemIdForEditor(String newProblemUrl) {
    final uri = Uri.parse(newProblemUrl);
    if (uri.host == 'atcoder.jp' &&
        uri.pathSegments.length == 4 &&
        uri.pathSegments[0] == 'contests' &&
        uri.pathSegments[2] == 'tasks') {
      final problemId = uri.pathSegments[3]; // e.g., abc388_a
      // Check if mounted before calling setState
      if (mounted) {
        setState(() {
          _currentProblemId = problemId;
        });
      }
      developer.log(
        'Editor Problem ID updated via ProblemDetailScreen: $_currentProblemId',
        name: 'MainScreen',
      );
    } else {
      developer.log(
        'Could not extract problem ID from URL: $newProblemUrl',
        name: 'MainScreen',
      );
    }
  }

  // Handles navigation from HomeScreen (WebView) - Now a class method
  void _navigateToProblemTabWithId(String problemId) {
    developer.log(
      '_navigateToProblemTabWithId called with problemId: $problemId',
      name: 'MainScreen',
    );
    if (mounted) {
      setState(() {
        _selectedIndex = 2; // Index of Problems tab
        _problemIdFromWebView = problemId; // Store the ID in the state variable
      });
    }
  }

  // Builds the list of screens - Now a class method
  List<Widget> _buildScreens() {
    String? idToPass = _problemIdFromWebView;
    developer.log(
      '_buildScreens: Passing problemIdToLoad=$idToPass',
      name: 'MainScreen',
    );

    // Reset the ID after using it in this build cycle.
    // Use addPostFrameCallback to schedule the reset after the build.
    if (_problemIdFromWebView != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        // Check if still mounted and if the ID hasn't been changed again by another event
        if (mounted && _problemIdFromWebView == idToPass) {
          setState(() {
            _problemIdFromWebView = null;
            developer.log(
              'Reset _problemIdFromWebView in post frame callback',
              name: 'MainScreen',
            );
          });
        }
      });
    }

    return [
      NewHomeScreen(
        key: const ValueKey('home'),
        isSelected: _selectedIndex == 0,
        onProblemSelected: _navigateToProblemTabWithId,
      ), // Index 0
      BrowserScreen(
        key: const ValueKey('browser'),
        navigateToProblem: _navigateToProblemTabWithId,
      ), // Index 1 - Use imported screen
      ProblemsScreen(
        // Index 2
        key: const ValueKey('problems'),
        problemIdToLoad: idToPass,
        onProblemChanged: _updateProblemIdForEditor,
      ),
      EditorScreen(
        // Index 3
        key: ValueKey('editor_$_currentProblemId'),
        problemId: _currentProblemId,
      ),
      SettingsScreen(key: const ValueKey('settings')), // Index 4
    ];
  }

  void _onItemTapped(int index) {
    if (index == _selectedIndex) {
      return;
    }

    // 触覚フィードバックを追加
    HapticFeedback.lightImpact();
    _hideKeyboard(context);
    // Check if mounted before calling setState
    if (mounted) {
      setState(() {
        _selectedIndex = index;
      });
    }
  }

  /// Hides the keyboard by unfocussing the current (textform) element
  ///
  /// 現在の（テキストフォーム）要素のフォーカスを外してキーボードを隠す
  void _hideKeyboard(BuildContext context) {
    FocusScope.of(context).unfocus();
  }

  @override
  Widget build(BuildContext context) {
    // Now _buildScreens is a class method and uses the state variable _problemIdFromWebView
    final screens = _buildScreens();

    final brightness = Theme.of(context).brightness;
    final overlayStyle = appSystemUiOverlayStyle(brightness);

    return GestureDetector(
      onTap: () {
        // Hide the keyboard on tap outside of the keyboard
        // キーボードの外側のタップでキーボードを隠す
        _hideKeyboard(context);
      },
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: overlayStyle,
        child: Scaffold(
          extendBody: true,
          body: SafeArea(
            // Browser and the M3E editor app bar need an external top inset.
            // The other tabs paint their own translucent app bar into it.
            top: _selectedIndex == 1 || _selectedIndex == 3,
            bottom:
                false, // allow content under BottomNavigationBar for BackdropFilter
            child: AnimatedTabStack(index: _selectedIndex, children: screens),
          ),
          bottomNavigationBar: TranslucentNavigationBackground(
            opacity: context.watch<ThemeProvider>().navBarOpacity,
            color: Theme.of(context).colorScheme.surface,
            child: Material(
              color: Colors.transparent,
              child: Center(
                heightFactor: 1,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(
                    maxWidth: ResponsiveLayout.maxContentWidth,
                  ),
                  child: AppBottomNavigation(
                    onDestinationSelected: _onItemTapped,
                    selectedIndex: _selectedIndex,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class AnimatedTabStack extends StatefulWidget {
  final int index;
  final List<Widget> children;

  const AnimatedTabStack({
    super.key,
    required this.index,
    required this.children,
  });

  @override
  State<AnimatedTabStack> createState() => _AnimatedTabStackState();
}

class _AnimatedTabStackState extends State<AnimatedTabStack>
    with SingleTickerProviderStateMixin {
  static const _duration = Duration(milliseconds: 280);
  static const _curve = Curves.easeOutCubic;

  late final AnimationController _controller;
  late Animation<double> _animation;
  int? _previousIndex;
  int _transitionDirection = 1;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: _duration)
      ..value = 1
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed && _previousIndex != null) {
          setState(() {
            _previousIndex = null;
          });
        }
      });
    _animation = CurvedAnimation(parent: _controller, curve: _curve);
  }

  @override
  void didUpdateWidget(covariant AnimatedTabStack oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.index != oldWidget.index) {
      if (MediaQuery.disableAnimationsOf(context)) {
        _controller.stop();
        _controller.value = 1;
        _previousIndex = null;
        return;
      }
      _previousIndex = oldWidget.index;
      _transitionDirection = widget.index > oldWidget.index ? 1 : -1;
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, _) {
        return Stack(
          fit: StackFit.expand,
          children: [
            for (var i = 0; i < widget.children.length; i++)
              _buildAnimatedChild(context, i),
          ],
        );
      },
    );
  }

  Widget _buildAnimatedChild(BuildContext context, int childIndex) {
    final isSelected = childIndex == widget.index;
    final isPrevious = childIndex == _previousIndex && _controller.isAnimating;
    final isVisible = isSelected || isPrevious;
    final progress = _animation.value;
    final textDirection = Directionality.of(context);
    final horizontalDirection = textDirection == TextDirection.rtl
        ? -_transitionDirection
        : _transitionDirection;

    double opacity;
    double slideOffset;
    if (isSelected) {
      opacity = progress;
      slideOffset = (1 - progress) * 0.06 * horizontalDirection;
    } else if (isPrevious) {
      opacity = 1 - progress;
      slideOffset = -progress * 0.06 * horizontalDirection;
    } else {
      opacity = 0;
      slideOffset = 0;
    }

    return Offstage(
      offstage: !isVisible,
      child: ExcludeFocus(
        excluding: !isSelected,
        child: TickerMode(
          enabled: isVisible,
          child: IgnorePointer(
            ignoring: !isSelected,
            child: FractionalTranslation(
              translation: Offset(slideOffset, 0),
              child: Opacity(
                opacity: opacity.clamp(0, 1),
                child: widget.children[childIndex],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ProblemsScreen はコールバックを受け取るように修正が必要
class ProblemsScreen extends StatelessWidget {
  final String? problemIdToLoad; // ID from WebView click
  final Function(String) onProblemChanged; // Callback for manual fetch

  const ProblemsScreen({
    super.key,
    this.problemIdToLoad,
    required this.onProblemChanged,
  });

  @override
  Widget build(BuildContext context) {
    // Add log to see the value being passed down
    developer.log(
      'ProblemsScreen build: problemIdToLoad=$problemIdToLoad',
      name: 'ProblemsScreen',
    );
    // Pass both the ID to load and the callback
    return ProblemDetailScreen(
      problemIdToLoad: problemIdToLoad, // Pass the ID down
      onProblemChanged: onProblemChanged, // Pass the callback down
    );
  }
}
