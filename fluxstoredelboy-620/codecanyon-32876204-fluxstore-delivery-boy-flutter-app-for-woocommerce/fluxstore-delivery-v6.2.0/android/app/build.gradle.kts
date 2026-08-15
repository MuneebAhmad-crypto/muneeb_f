import java.util.Properties

plugins {
    id("com.android.application")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
    id("com.google.gms.google-services")
}

val localProperties = Properties().apply {
    val f = rootProject.file("local.properties")
    if (f.exists()) f.reader(Charsets.UTF_8).use { load(it) }
}

val flutterVersionCode: String = localProperties.getProperty("flutter.versionCode") ?: "1"
val flutterVersionName: String = localProperties.getProperty("flutter.versionName") ?: "1.0"

val envProperties = Properties()
val envPropsFile = rootProject.file("../configs/env.props")
val envPropertiesFile = rootProject.file("../configs/env.properties")

if (envPropertiesFile.exists() && envPropsFile.exists()) {
    println("=====================================================================")
    println("⚠️  Warning: env.properties is deprecated, please rename to env.props")
    println("=====================================================================")
}

if (envPropertiesFile.exists() && !envPropsFile.exists()) {
    println("=================================================================")
    println("⚠️  Warning: env.properties is deprecated and should not be used")
    println("🪄️  env.properties has been renamed to env.props automatically")
    println("=================================================================")
    envPropertiesFile.renameTo(envPropsFile)
}

if (envPropsFile.exists()) {
    println("🔧 Loading configs from configs/env.props...\n")
    envPropsFile.reader(Charsets.UTF_8).use { envProperties.load(it) }
} else if (envPropertiesFile.exists()) {
    println("🔧 Loading configs from configs/env.properties...\n")
    envPropertiesFile.reader(Charsets.UTF_8).use { envProperties.load(it) }
}

fun env(key: String, default: String = ""): String = envProperties.getProperty(key, default)

android {
    namespace = "com.inspireui.fluxstore"
    compileSdk = 36

    // Force usage of specific version of NDK due to 16 KB native library
    // alignment requirement from Google Play.
    // Ref:
    // https://github.com/rive-app/rive-flutter/issues/479
    // https://github.com/rive-app/rive-flutter/commit/90c91f60afbe7a13819edb8ef8ebdff7eb5c6110
    // https://developer.android.com/guide/practices/page-sizes#compile-r28
    ndkVersion = "28.2.13676358"

    sourceSets["main"].java.srcDirs("src/main/kotlin")

    compileOptions {
        // Flag to enable support for the new language APIs
        isCoreLibraryDesugaringEnabled = true

        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    tasks.withType(JavaCompile::class.java).configureEach {
        options.isWarnings = false
    }

    defaultConfig {
        applicationId = env("androidPackageName")
        minSdk = 26
        targetSdk = 35

        versionCode = flutterVersionCode.toInt()
        versionName = flutterVersionName
        testInstrumentationRunner = "androidx.test.runner.AndroidJUnitRunner"

        // // Zoho SalesIQ Mobilisten
        // Comment `resourceConfigurations += "en"` to fix Zoho SaleIQ not support
        // multi-language on Android.
        // Un-comment to reduce build size.
        resourceConfigurations += "en"

        // Using `manifestPlaceholders` will replace the param on
        // `AndroidManifest.xml` file with the correct value.
        manifestPlaceholders.putAll(
            mapOf(
                "envatoPurchaseCode" to env("envatoPurchaseCode"),
                "websiteUrl" to env("websiteUrl"),
                "websiteDomain" to env("websiteDomain"),
                "customScheme" to env("customScheme"),
                "googleApiKeyAndroid" to env("googleApiKeyAndroid"),
                "adMobAppIdAndroid" to env("adMobAppIdAndroid"),
                "facebookClientToken" to env("facebookClientToken"),
                "facebookLoginProtocolScheme" to env("facebookLoginProtocolScheme"),
                "branchKeyLive" to env("branchKeyLive"),
                "branchKeyTest" to env("branchKeyTest"),
                "branchLiveLinkDomain" to env("branchLiveLinkDomain"),
                "branchLiveAlternateLinkDomain" to env("branchLiveAlternateLinkDomain"),
                "branchTestLinkDomain" to env("branchTestLinkDomain"),
                "branchTestAlternateLinkDomain" to env("branchTestAlternateLinkDomain"),
                "branchTestMode" to env("branchTestMode"),
                "shopUrl" to env("shopUrl"),
                "fluxDynamicLinkScheme" to env("fluxDynamicLinkScheme"),
                "fluxDynamicLinkHost" to env("fluxDynamicLinkHost"),
            )
        )

        // If you use `resValue`, it will generate a resource of the type you
        // specify into your app's res directory.
        resValue("string", "facebookAppId", env("facebookAppId"))

        // Not sure why we need to use `appName` as resValue.
        resValue("string", "app_name", env("appName").replace("'", "\\'"))

        // Notification color for Firebase
        resValue("color", "notification_color", "#" + env("notificationColor", "FF2EB0FE"))

        // Notification color for OneSignal
        resValue("string", "onesignal_notification_accent_color", env("notificationColor", "FF2EB0FE"))
    }

    signingConfigs {
        create("release") {
            keyAlias = env("keyAlias")
            keyPassword = env("keyPassword")
            storeFile = rootProject.file("../configs/" + env("storeFile"))
            storePassword = env("storePassword")
        }
    }

    buildTypes {
        release {
            // Signing with the release keys configured in env.props.
            signingConfig = signingConfigs.getByName("release")

            proguardFiles(getDefaultProguardFile("proguard-android-optimize.txt"), "proguard-rules.pro")
        }

        debug {
            signingConfig = signingConfigs.getByName("release")
        }
    }

    packaging {
        jniLibs {
            useLegacyPackaging = true
        }
    }

    lint {
        checkReleaseBuilds = false
        disable += "InvalidPackage"
    }
}

kotlin {
    compilerOptions {
        jvmTarget = org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17
    }
}

flutter {
    source = "../.."
}

dependencies {
    testImplementation("junit:junit:4.13.2")
    androidTestImplementation("androidx.test:runner:1.6.2")
    androidTestImplementation("androidx.test.espresso:espresso-core:3.6.1")

    implementation("com.google.android.material:material:1.12.0")
    implementation("com.android.support:multidex:1.0.3")
    implementation("androidx.browser:browser:1.8.0")
    implementation("androidx.lifecycle:lifecycle-viewmodel-ktx:2.8.6")

    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
}

googleServices { disableVersionCheck = true }

val srcFolderConfig = "../../configs/"
val srcFolderCustomized = "../../configs/customized/"
val destFolderGoogleService = "./"
val destFolderCustomized = "../../"
val destFolderNotificationIcon = "./src/main/res/drawable/"
val notificationIcon: String = env("notificationIcon")

// Perform config-file copies eagerly during configuration. This intentionally
// avoids registering Gradle tasks because the destinations overlap with
// other tasks' inputs/outputs (pubspec.yaml, jniLibs, etc.) which Gradle
// 8.13's strict task validation would otherwise flag as implicit
// dependencies across every consumer task. Running at configuration time
// guarantees the files are in place before any task graph executes.
println("🔧 Copying configs/customized to project...")
copy {
    from(srcFolderCustomized)
    into(destFolderCustomized)
    include("**")
    exclude("**/.DS_Store")
    exclude("**/Thumbs.db")
    duplicatesStrategy = DuplicatesStrategy.INCLUDE
}

println("🔧 Copying configs/google-services.json to android/app/google-services.json")
copy {
    from(srcFolderConfig)
    into(destFolderGoogleService)
    include("google-services.json")
    duplicatesStrategy = DuplicatesStrategy.INCLUDE
}

val notificationIconFile = rootProject.file("../configs/$notificationIcon")
if (notificationIcon.isNotEmpty() && notificationIconFile.exists()) {
    println("🔧 Copying configs/" + notificationIcon + " to " + destFolderNotificationIcon + "ic_stat_onesignal_default.png")
    copy {
        from(srcFolderConfig)
        into(destFolderNotificationIcon)
        include(notificationIcon)
        duplicatesStrategy = DuplicatesStrategy.INCLUDE
        rename { fileName -> fileName.replace(notificationIcon, "ic_stat_onesignal_default.png") }
    }
    val originalFile = rootProject.file(destFolderNotificationIcon + notificationIcon)
    if (originalFile.exists()) originalFile.delete()
}

/// Pre-build banner
tasks.named("preBuild") {
    doFirst {
        println("\n🪄  Building " + env("appName") + "... 🪄\n")
        println("\n🔑 Signing with keystore " + env("storeFile") + "... 🔑\n")
    }
}
