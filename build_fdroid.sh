#!/bin/bash

# F-Droid compatible build script for shojin_app
# This script demonstrates how to build the app in F-Droid compatible mode

echo "Building Shojin App for F-Droid..."

# Set F-Droid build flags
export FDROID_BUILD=true
export ENABLE_SELF_UPDATE=false
export ENABLE_ONLINE_FONTS=false

echo "Build flags set:"
echo "  FDROID_BUILD=$FDROID_BUILD"
echo "  ENABLE_SELF_UPDATE=$ENABLE_SELF_UPDATE"  
echo "  ENABLE_ONLINE_FONTS=$ENABLE_ONLINE_FONTS"

# Clean previous builds
flutter clean

# Get dependencies
echo "Getting Flutter dependencies..."
flutter pub get

# Build the APK with F-Droid flags
echo "Building APK with F-Droid compatibility flags..."
flutter build apk \
  --dart-define=FDROID_BUILD=true \
  --dart-define=ENABLE_SELF_UPDATE=false \
  --dart-define=ENABLE_ONLINE_FONTS=false \
  --flavor=fdroid \
  --release

echo "F-Droid compatible build completed!"
echo "APK location: build/app/outputs/flutter-apk/app-fdroid-release.apk"

# Verify the build
if [ -f "build/app/outputs/flutter-apk/app-fdroid-release.apk" ]; then
    echo "✅ F-Droid APK build successful"
    
    # Get APK size
    APK_SIZE=$(stat -f%z "build/app/outputs/flutter-apk/app-fdroid-release.apk" 2>/dev/null || stat -c%s "build/app/outputs/flutter-apk/app-fdroid-release.apk" 2>/dev/null)
    echo "📦 APK size: $(echo $APK_SIZE | awk '{ printf "%.2f MB", $1/1024/1024 }')"
else
    echo "❌ F-Droid APK build failed"
    exit 1
fi

echo ""
echo "F-Droid build notes:"
echo "• Self-update functionality is disabled"
echo "• Online font fetching is disabled (uses system fonts)"
echo "• Git dependencies are abstracted (would need vendoring for actual F-Droid submission)"
echo "• Font licenses are documented in FONT_LICENSES.md"
echo ""
echo "For actual F-Droid submission, ensure:"
echo "1. Git dependencies are replaced with pub.dev versions or vendored code"
echo "2. All third-party licenses are properly documented"
echo "3. No proprietary or non-free network services dependencies"