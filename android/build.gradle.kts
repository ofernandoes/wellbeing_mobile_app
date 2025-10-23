plugins {
    id("com.android.application")
    kotlin("android")
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    // FIX 1: compileSdkVersion requires a String
    compileSdkVersion = "34" 
    
    // IMPORTANT: CHANGE THIS TO YOUR ACTUAL PACKAGE NAME! 
    namespace = "com.example.wellbeing_mobile_app"

    defaultConfig {
        applicationId = "com.example.wellbeing_mobile_app"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    // Configure Java/Kotlin compatibility to fix obsolete warnings
    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = "17" 
    }

    // Configuration for the build types (debug, release)
    buildTypes {
        release {
            // shrinkResources = true
            // minifyEnabled = true
            // proguardFiles(getDefaultProguardFile("proguard-android-optimize.txt"), "proguard-rules.pro")
        }
    }

    // New packaging syntax to fix resource conflict errors (META-INF)
    packaging {
        resources {
            excludes += "META-INF/licenses/*"
            excludes += "META-INF/*.md"
            excludes += "META-INF/*.txt"
        }
    }
}

flutter {
    // FIX 2: source must be a simple string path, NOT file("../..")
    source = "../.."
}

dependencies {
    // Re-add any custom Android/Kotlin dependencies your project had here!
}
