import 'package:flutter_test/flutter_test.dart';
import 'package:shojin_app/config/build_config.dart';

void main() {
  group('BuildConfig Tests', () {
    test('should have correct default values for regular builds', () {
      // These values should match what we get without any dart-define flags
      // Note: In test environment, bool.fromEnvironment returns false by default
      
      // Test that F-Droid detection works
      expect(BuildConfig.isF_DroidBuild, false, 
        reason: 'F-Droid build flag should be false by default');
        
      // Test self-update flag behavior
      // Without FDROID_BUILD=true, enableSelfUpdate should follow ENABLE_SELF_UPDATE or default to true
      // In test environment this will be false since bool.fromEnvironment defaults to false
      expect(BuildConfig.enableSelfUpdate, false,
        reason: 'Self-update should be controlled by environment variable');
        
      // Test online fonts flag behavior  
      expect(BuildConfig.enableOnlineFonts, false,
        reason: 'Online fonts should be controlled by environment variable');
    });
    
    test('should provide repository configuration', () {
      expect(BuildConfig.defaultOwner, 'yuubinnkyoku');
      expect(BuildConfig.defaultRepo, 'Shojin_App');
    });
    
    test('build config constants should be compile-time constants', () {
      // This ensures the flags can be used in const contexts and dead code elimination
      const isFdroid = BuildConfig.isF_DroidBuild;
      const selfUpdate = BuildConfig.enableSelfUpdate;
      const onlineFonts = BuildConfig.enableOnlineFonts;
      
      expect(isFdroid, isA<bool>());
      expect(selfUpdate, isA<bool>());
      expect(onlineFonts, isA<bool>());
    });
  });
}