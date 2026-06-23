import 'package:flutter_test/flutter_test.dart';
import 'package:shojin_app/config/build_config.dart';
import 'package:shojin_app/services/android_package_service.dart';

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

    test(
      'getInstallStatusByCode should return correct status for known codes',
      () {
        // Test status code mapping
        expect(
          AndroidPackageService.getInstallStatusByCode(0),
          InstallStatus.success,
        );
        expect(
          AndroidPackageService.getInstallStatusByCode(-1),
          InstallStatus.pending,
        );
        expect(
          AndroidPackageService.getInstallStatusByCode(-2),
          InstallStatus.failureAborted,
        );
        expect(
          AndroidPackageService.getInstallStatusByCode(-3),
          InstallStatus.failureBlocked,
        );
        expect(
          AndroidPackageService.getInstallStatusByCode(-4),
          InstallStatus.failureConflict,
        );
        expect(
          AndroidPackageService.getInstallStatusByCode(-5),
          InstallStatus.failureIncompatible,
        );
        expect(
          AndroidPackageService.getInstallStatusByCode(-6),
          InstallStatus.failureInvalid,
        );
        expect(
          AndroidPackageService.getInstallStatusByCode(-7),
          InstallStatus.failureStorage,
        );
        expect(
          AndroidPackageService.getInstallStatusByCode(999),
          InstallStatus.unknown,
        );
        expect(
          AndroidPackageService.getInstallStatusByCode(null),
          InstallStatus.unknown,
        );
      },
    );

    test('build flag and package service behavior stay consistent', () async {
      if (BuildConfig.enableSelfUpdate) {
        expect(
          AndroidPackageService.getInstallStatusByCode(0),
          InstallStatus.success,
        );
      } else {
        expect(
          () => AndroidPackageService.installApk('/fake/path.apk'),
          throwsA(isA<UnsupportedError>()),
        );
        expect(
          AndroidPackageService.getInstallStatusByCode(0),
          InstallStatus.failure,
        );
        expect(await AndroidPackageService.canInstallApks(), false);
      }
    });
  });
}
