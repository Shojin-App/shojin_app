import 'package:flutter/foundation.dart';

/// webview_flutter currently has an embedded implementation on these targets.
bool get supportsEmbeddedWebView =>
    !kIsWeb &&
    const {
      TargetPlatform.android,
      TargetPlatform.iOS,
      TargetPlatform.macOS,
    }.contains(defaultTargetPlatform);
