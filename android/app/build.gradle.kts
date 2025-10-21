	plugins {
    id("com.android.application")
    // Include the Kotlin Android plugin if your project uses Kotlin for native code
    kotlin("android")
    // The Flutter Gradle plugin must be applied after the Android and Kotlin plugins
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    // Set to your project's compile SDK version
    compileSdk = 36
    namespace = "com.example.wellbeing_mobile_app"

    defaultConfig {
        // !!! IMPORTANT: CHANGE THIS TO YOUR ACTUAL PACKAGE NAME !!!
        applicationId = "com.example.wellbeing_mobile_app"

        minSdk = flutter.minSdkVersion
        targetSdk = 34
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    // New packaging syntax to fix resource conflict errors (META-INF)
    packaging {
        resources {
            excludes.add("META-INF/AL2.0")
            excludes.add("META-INF/LGPL2.1")
            excludes.add("META-INF/LICENSE.md")
            excludes.add("META-INF/LICENSE-notice.md")
        }
    }

    // Configuration for the build types (debug, release)
    buildTypes {
        release {
            // Uncomment and configure if needed for production release
            // shrinkResources = true
            // minifyEnabled = true
            // proguardFiles(
            //     getDefaultProguardFile("proguard-android-optimize.txt"),
            //     "proguard-rules.pro"
            // )
        }
    }

    // Configure Java/Kotlin compatibility
    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = "17"
    }
}

flutter {
    // Corrected syntax for the source path (string instead of file())
    source = "../.."
}

dependencies {
    // Re-add any custom Android/Kotlin dependencies your project had here!
}
