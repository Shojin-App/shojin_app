// ignore_for_file: unused_import
import 'dart:io';

// Conditional import for Android package installer - only for non-F-Droid builds
// Removed external Git dependencies (android_package_installer / android_package_manager)
// for F-Droid compliance (vendor/stub approach). All functionality is now
// either disabled when self-update is off or implemented via platform channels
// in future if needed. The previous imports are intentionally commented out.
//
// If upstream functionality is reintroduced, prefer:
// 1. Adding a vendored minimal implementation under lib/vendor/
// 2. Or using a published pub.dev package (not raw git) with a fixed version.
//
// import 'package:android_package_installer/android_package_installer.dart' as apm_installer;
// import 'package:android_package_manager/android_package_manager.dart' as apm_manager;
import 'package:flutter/services.dart';

import '../config/build_config.dart';

/// Installation status - abstraction to avoid Git dependency issues
enum InstallStatus {
  success,
  failure,
  failureAborted,
  failureBlocked,
  failureConflict,
  failureIncompatible,
  failureInvalid,
  failureStorage,
  unknown,
  pending,
}

/// Wrapper for Android package operations with F-Droid compatibility
class AndroidPackageService {
  /// Install APK file - disabled for F-Droid builds
  static Future<int?> installApk(String path) async {
    if (!BuildConfig.enableSelfUpdate) {
      throw UnsupportedError('APK installation is disabled for F-Droid builds');
    }

    if (!Platform.isAndroid) {
      throw UnsupportedError('APK installation is only supported on Android');
    }

    try {
      // Use the Android package installer for non-F-Droid builds
      // Previously used AndroidPackageInstaller (external Git dependency).
      // Now this path is intentionally unreachable in F-Droid builds because
      // enableSelfUpdate will be false there. For non-F-Droid builds you may
      // plug in a platform channel or a vendored implementation.
      throw UnimplementedError(
        'APK install implementation removed (vendor stub)',
      );
    } catch (e) {
      throw Exception('Failed to install APK: $e');
    }
  }

  /// Convert status code to InstallStatus
  static InstallStatus getInstallStatusByCode(int? statusCode) {
    if (!BuildConfig.enableSelfUpdate) {
      return InstallStatus.failure;
    }

    if (statusCode == null) return InstallStatus.unknown;
    if (statusCode == -1) return InstallStatus.pending;

    try {
      // Map the status codes from android_package_installer
      // This is a simplified version to avoid direct dependency
      switch (statusCode) {
        case 0:
          return InstallStatus.success;
        case -1:
          return InstallStatus.pending;
        case -2:
          return InstallStatus.failureAborted;
        case -3:
          return InstallStatus.failureBlocked;
        case -4:
          return InstallStatus.failureConflict;
        case -5:
          return InstallStatus.failureIncompatible;
        case -6:
          return InstallStatus.failureInvalid;
        case -7:
          return InstallStatus.failureStorage;
        default:
          return InstallStatus.unknown;
      }
    } catch (e) {
      return InstallStatus.unknown;
    }
  }

  /// Check if an APK can be installed - always false for F-Droid builds
  static Future<bool> canInstallApks() async {
    if (!BuildConfig.enableSelfUpdate) {
      return false;
    }

    if (!Platform.isAndroid) {
      return false;
    }

    // NOTE:
    // 以前は android_package_manager の `AndroidPackageManager.getInstalledPackages` を
    // 呼び出してインストール可能かどうかを間接的に判定していたが、プラグインのAPI変更により
    // ビルド時に解決できなくなったため、ここでは最小限のプラットフォームガードのみとする。
    // 実際のインストール可否は installApk 実行時の例外で判断される。
    return true;
  }

  /// Get app version - fallback implementation for F-Droid builds
  static Future<String> getAppVersion() async {
    if (!Platform.isAndroid) {
      return 'unknown';
    }

    try {
      // For F-Droid builds, we can still try to get basic package info
      // This doesn't require the problematic Git dependencies
      const platform = MethodChannel('app_version');
      final version = await platform.invokeMethod('getVersion');
      return version ?? 'unknown';
    } catch (e) {
      return 'unknown';
    }
  }
}
