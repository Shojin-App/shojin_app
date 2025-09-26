import 'package:flutter_test/flutter_test.dart';
import 'package:shojin_app/services/android_package_service.dart';
import 'package:shojin_app/config/build_config.dart';

void main() {
  group('AndroidPackageService Tests', () {
    test('should have correct InstallStatus enum values', () {
      // Test that all expected status values exist
      expect(InstallStatus.success, isNotNull);
      expect(InstallStatus.failure, isNotNull);
      expect(InstallStatus.failureAborted, isNotNull);
      expect(InstallStatus.failureBlocked, isNotNull);
      expect(InstallStatus.failureConflict, isNotNull);
      expect(InstallStatus.failureIncompatible, isNotNull);
      expect(InstallStatus.failureInvalid, isNotNull);
      expect(InstallStatus.failureStorage, isNotNull);
      expect(InstallStatus.unknown, isNotNull);
      expect(InstallStatus.pending, isNotNull);
    });
    
    test('getInstallStatusByCode should return correct status for known codes', () {
      // Test status code mapping
      expect(AndroidPackageService.getInstallStatusByCode(0), InstallStatus.success);
      expect(AndroidPackageService.getInstallStatusByCode(-1), InstallStatus.pending);
      expect(AndroidPackageService.getInstallStatusByCode(-2), InstallStatus.failureAborted);
      expect(AndroidPackageService.getInstallStatusByCode(-3), InstallStatus.failureBlocked);
      expect(AndroidPackageService.getInstallStatusByCode(-4), InstallStatus.failureConflict);
      expect(AndroidPackageService.getInstallStatusByCode(-5), InstallStatus.failureIncompatible);
      expect(AndroidPackageService.getInstallStatusByCode(-6), InstallStatus.failureInvalid);
      expect(AndroidPackageService.getInstallStatusByCode(-7), InstallStatus.failureStorage);
      expect(AndroidPackageService.getInstallStatusByCode(999), InstallStatus.unknown);
      expect(AndroidPackageService.getInstallStatusByCode(null), InstallStatus.unknown);
    });
    
    test('should reject APK installation when self-update is disabled', () async {
      // Since we're in a test environment without dart-define flags,
      // BuildConfig.enableSelfUpdate should be false
      expect(BuildConfig.enableSelfUpdate, false);
      
      // This should throw UnsupportedError for F-Droid builds
      expect(() => AndroidPackageService.installApk('/fake/path.apk'), 
        throwsA(isA<UnsupportedError>()));
    });
    
    test('getInstallStatusByCode should return failure when self-update disabled', () {
      // When self-update is disabled, status should always be failure
      expect(AndroidPackageService.getInstallStatusByCode(0), InstallStatus.failure);
      expect(AndroidPackageService.getInstallStatusByCode(-1), InstallStatus.failure);
    });
    
    test('canInstallApks should return false when self-update disabled', () async {
      // Should always return false for F-Droid builds
      expect(await AndroidPackageService.canInstallApks(), false);
    });
  });
}