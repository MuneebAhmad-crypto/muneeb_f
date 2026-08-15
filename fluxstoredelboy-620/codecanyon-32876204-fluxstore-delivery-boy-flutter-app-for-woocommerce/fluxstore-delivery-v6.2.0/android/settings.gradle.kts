pluginManagement {
    val flutterSdkPath =
        run {
            val properties = java.util.Properties()
            file("local.properties").inputStream().use { properties.load(it) }
            val flutterSdkPath = properties.getProperty("flutter.sdk")
            require(flutterSdkPath != null) { "flutter.sdk not set in local.properties" }
            flutterSdkPath
        }

    includeBuild("$flutterSdkPath/packages/flutter_tools/gradle")

    repositories {
        google()
        mavenCentral()
        gradlePluginPortal()
    }
}

plugins {
    id("dev.flutter.flutter-plugin-loader") version "1.0.0"
    id("com.android.application") version "8.13.0" apply false
    id("org.jetbrains.kotlin.android") version "2.3.21" apply false
    id("com.google.gms.google-services") version "4.3.14" apply false // New version 4.4.0 will cause crash app after reopen app from background
}

// `kotlin-android` is the legacy id used by `id("kotlin-android")` in app/build.gradle.kts.
// It is mapped to `org.jetbrains.kotlin.android` above.

include(":app")
