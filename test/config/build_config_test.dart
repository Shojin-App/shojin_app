import 'package:flutter_test/flutter_test.dart';
import 'package:shojin_app/config/build_config.dart';

void main() {
  group('BuildConfig Tests', () {
    test('should have correct default values for regular builds', () {
      // These values should match what we get without any dart-define flags
      // Note: In test environment, bool.fromEnvironment returns false by default

      // Test that F-Droid detection works
      expect(
        BuildConfig.isFdroidBuild,
        false,
        reason: 'F-Droid build flag should be false by default',
      );

      // Test self-update flag behavior
      // Without FDROID_BUILD=true, enableSelfUpdate should follow ENABLE_SELF_UPDATE or default to true
      // In test environment this will be false since bool.fromEnvironment defaults to false
      expect(
        BuildConfig.enableSelfUpdate,
        true,
        reason: 'Self-update defaults to enabled outside F-Droid builds',
      );

      // Test online fonts flag behavior
      expect(
        BuildConfig.enableOnlineFonts,
        true,
        reason: 'Online fonts default to enabled outside F-Droid builds',
      );
    });

    test('should provide repository configuration', () {
      expect(BuildConfig.defaultOwner, 'Shojin-App');
      expect(BuildConfig.defaultRepo, 'Shojin_App');
    });

    test('build config constants should be compile-time constants', () {
      // This ensures the flags are evaluable without runtime errors
      final isFdroid = BuildConfig.isFdroidBuild;
      final selfUpdate = BuildConfig.enableSelfUpdate;
      final onlineFonts = BuildConfig.enableOnlineFonts;

      expect(isFdroid, isA<bool>());
      expect(selfUpdate, isA<bool>());
      expect(onlineFonts, isA<bool>());
    });
  });
}
