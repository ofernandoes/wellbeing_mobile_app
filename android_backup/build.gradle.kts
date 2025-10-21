buildscript {
    // ext.kotlin_version is not needed here if it's set in the app module
    repositories {
        google()
        mavenCentral()
    }
    dependencies {
        // AGP downgrade fix (7.4.2)
        classpath("com.android.tools.build:gradle:7.4.2")
        // Kotlin version must be set here and *not* in the app module's 'plugins' block
        classpath("org.jetbrains.kotlin:kotlin-gradle-plugin:1.6.21")
    }
}

allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

tasks.register("clean", Delete::class) {
    delete(rootProject.buildDir)
}
