plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "io.github.shojinapp.kyopro"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = "28.0.13004108"

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
        // Add the following line
        isCoreLibraryDesugaringEnabled = true
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    buildFeatures {
        buildConfig = true
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
    applicationId = "io.github.shojinapp.kyopro"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName

        // When building without specifying a flavor, pick 'oss' by default
        // so Flutter can locate the output APK without ambiguity.
        missingDimensionStrategy("dist", "oss")
    }

    flavorDimensions += listOf("dist")
    productFlavors {
        create("fdroid") {
            dimension = "dist"
            applicationIdSuffix = ".fdroid"
            resValue("bool", "enable_self_update", "false")
            buildConfigField("boolean", "FDROID_BUILD", "true")
        }
        create("oss") {
            dimension = "dist"
            resValue("bool", "enable_self_update", "true")
            buildConfigField("boolean", "FDROID_BUILD", "false")
        }
    }

    buildTypes {
        release {
            // TODO: Add your own signing config for the release build.
            // Signing with the debug keys for now, so `flutter run --release` works.
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}

// Add the following block
dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
}
