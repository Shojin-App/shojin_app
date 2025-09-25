// ignore_for_file: unused_import
import 'dart:io';
import 'package:flutter/services.dart';
import '../config/build_config.dart';

// Conditional import for Android package installer - only for non-F-Droid builds
import 'package:android_package_installer/android_package_installer.dart' as apm_installer
    if (dart.library.js) 'package:android_package_installer/android_package_installer.dart';
import 'package:android_package_manager/android_package_manager.dart' as apm_manager
    if (dart.library.js) 'package:android_package_manager/android_package_manager.dart';

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
      return await apm_installer.AndroidPackageInstaller.installApk(apkFilePath: path);
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

    try {
      // Use the Android package manager for non-F-Droid builds
      return await apm_manager.AndroidPackageManager.getInstalledPackages(
        includeAppIcons: false,
        includeSystemApps: false,
      ).then((_) => true);
    } catch (e) {
      return false;
    }
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