plugins {
    id("com.android.application")
    kotlin("android")
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    // Set to your project's compile SDK version (36 is the common default now)
    compileSdkVersion = "android-36" 
    
    // IMPORTANT: CHANGE THIS TO YOUR ACTUAL PACKAGE NAME! 
    // Example: "com.ofernandoes.wellbeingapp" 
    namespace = "com.example.wellbeing_mobile_app"

    defaultConfig {
        applicationId = "com.example.wellbeing_mobile_app"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    // Configure Java/Kotlin compatibility to fix obsolete warnings
    // Setting to 17 for stability and to match modern Flutter requirements
    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        // Set JVM Target to 17 for consistency with compileOptions
        jvmTarget = "17" 
    }

    // Configuration for the build types (debug, release)
    buildTypes {
        release {
            // Uncomment and configure if needed for production release
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
    source = "../.."
}

dependencies {
    // Re-add any custom Android/Kotlin dependencies your project had here!
}
