/// Build configuration for F-Droid compliance and other build variants
class BuildConfig {
  /// Flag to determine if this is an F-Droid build
  /// When true, disables self-update functionality and online font fetching
  static const bool isFdroidBuild = bool.fromEnvironment(
    'FDROID_BUILD',
    defaultValue: false,
  );

  /// Flag to control self-update functionality
  /// Disabled automatically for F-Droid builds
  static const bool enableSelfUpdate =
      bool.fromEnvironment('ENABLE_SELF_UPDATE', defaultValue: true) &&
      !isFdroidBuild;

  /// Flag to control online font fetching
  /// Disabled for F-Droid builds to ensure offline-only operation
  static const bool enableOnlineFonts =
      bool.fromEnvironment('ENABLE_ONLINE_FONTS', defaultValue: true) &&
      !isFdroidBuild;

  /// Repository info for self-updates (only used when enableSelfUpdate is true)
  static const String defaultOwner = 'Shojin-App';
  static const String defaultRepo = 'Shojin_App';
}
