allprojects {
    repositories {
        google()
        mavenCentral()

        // // Zoho SalesIQ Mobilisten
        // maven { url = uri("https://maven.zohodl.com") }

        maven { url = uri("https://phonepe.mycloudrepo.io/public/repositories/phonepe-intentsdk-android") }
    }
}

val newBuildDir: Directory =
    rootProject.layout.buildDirectory
        .dir("../../build")
        .get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}

// Workaround applied to every Flutter plugin module:
// - Force a minimum compileSdk for plugins that still target older SDKs.
//   Ref: https://github.com/flutter/flutter/issues/153281#issuecomment-2292201697
// - Upgrade Java/Kotlin target to 17 to match AGP 9.x requirement.
// - Add the missing `namespace` (required by AGP 8+/9+) using the plugin's group.
subprojects {
    afterEvaluate {
        val androidExt = extensions.findByName("android") ?: return@afterEvaluate

        // Use reflection so we do not depend on AGP types at the root build script
        // classpath (which would require an explicit buildscript classpath entry).
        try {
            // Bump compileSdk for plugins still on < 35.
            val getCompileSdk = androidExt.javaClass.methods.firstOrNull { it.name == "getCompileSdkVersion" }
            val currentCompileSdk = getCompileSdk?.invoke(androidExt) as? String
            val currentCompileSdkInt = currentCompileSdk?.removePrefix("android-")?.toIntOrNull() ?: 0
            if (currentCompileSdkInt in 1..34) {
                val setCompileSdk = androidExt.javaClass.methods.firstOrNull { it.name == "setCompileSdkVersion" && it.parameterTypes.size == 1 && it.parameterTypes[0] == Int::class.javaPrimitiveType }
                setCompileSdk?.invoke(androidExt, 35)
            }
        } catch (_: Throwable) { }

        // Patch the namespace if the plugin did not declare one.
        try {
            val getNamespace = androidExt.javaClass.methods.firstOrNull { it.name == "getNamespace" }
            val setNamespace = androidExt.javaClass.methods.firstOrNull { it.name == "setNamespace" && it.parameterTypes.size == 1 && it.parameterTypes[0] == String::class.java }
            val currentNs = getNamespace?.invoke(androidExt) as? String
            if (currentNs.isNullOrEmpty()) {
                val fallback = project.group.toString().ifEmpty { "com.flutter.plugin.${project.name.replace('-', '_')}" }
                setNamespace?.invoke(androidExt, fallback)
            }
        } catch (_: Throwable) { }

        // Align Java/Kotlin target to 17 (AGP 9 minimum).
        if (project.plugins.hasPlugin("kotlin-android")) {
            project.tasks.withType(org.jetbrains.kotlin.gradle.tasks.KotlinCompile::class.java).configureEach {
                compilerOptions {
                    jvmTarget.set(org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17)
                }
            }
        }
        project.tasks.withType(JavaCompile::class.java).configureEach {
            sourceCompatibility = JavaVersion.VERSION_17.toString()
            targetCompatibility = JavaVersion.VERSION_17.toString()
        }

        // Force AGP's android { compileOptions { ... } } to JVM 17 as well so
        // that the eventual JavaCompile task picks up matching source/target
        // (otherwise plugins that hard-code 1.8/11 mismatch Kotlin's 17).
        try {
            val getCompileOptions = androidExt.javaClass.methods.firstOrNull { it.name == "getCompileOptions" }
            val compileOptions = getCompileOptions?.invoke(androidExt)
            if (compileOptions != null) {
                val setSource = compileOptions.javaClass.methods.firstOrNull { it.name == "setSourceCompatibility" && it.parameterTypes.size == 1 && it.parameterTypes[0] == JavaVersion::class.java }
                val setTarget = compileOptions.javaClass.methods.firstOrNull { it.name == "setTargetCompatibility" && it.parameterTypes.size == 1 && it.parameterTypes[0] == JavaVersion::class.java }
                setSource?.invoke(compileOptions, JavaVersion.VERSION_17)
                setTarget?.invoke(compileOptions, JavaVersion.VERSION_17)
            }
        } catch (_: Throwable) { }
    }
}

subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
