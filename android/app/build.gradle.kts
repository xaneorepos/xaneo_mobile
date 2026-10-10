import java.net.URI
import java.util.Base64
import org.jetbrains.kotlin.gradle.dsl.JvmTarget

val buildDefines = (project.findProperty("dart-defines") as? String).orEmpty()
    .split(',')
    .mapNotNull { encoded ->
        runCatching { String(Base64.getDecoder().decode(encoded), Charsets.UTF_8) }.getOrNull()
    }
val configuredApiUrl = buildDefines.firstOrNull { it.startsWith("API_BASE_URL=") }
    ?.substringAfter('=')
    ?: buildDefines.firstOrNull { it.startsWith("BASE_URL=") }?.substringAfter('=')
    ?: "https://xaneo.ru/api/v1"
val buildHost = runCatching { URI(configuredApiUrl).host?.lowercase().orEmpty() }
    .getOrDefault("")
val localBuildHost = buildHost == "localhost" || buildHost.endsWith(".local") ||
    buildHost == "::1" || buildHost.startsWith("127.") ||
    buildHost.startsWith("10.") || buildHost.startsWith("192.168.") ||
    buildHost.startsWith("169.254.") ||
    (buildHost.contains(':') && (buildHost.startsWith("fc") ||
        buildHost.startsWith("fd") || buildHost.startsWith("fe80:"))) ||
    (buildHost.startsWith("172.") &&
        buildHost.split('.').getOrNull(1)?.toIntOrNull()?.let { it in 16..31 } == true)

plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "net.xaneo"
    compileSdk = flutter.compileSdkVersion
    // ndkVersion = flutter.ndkVersion

    compileOptions {
        isCoreLibraryDesugaringEnabled = true
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    defaultConfig {
        // A local API build has its own Android app data and can coexist with production.
        applicationId = if (localBuildHost) "net.xaneo.beta" else "net.xaneo"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
        multiDexEnabled = true
        manifestPlaceholders["appLabel"] = if (localBuildHost) "Xaneo Beta" else "Xaneo"
    }

    buildTypes {
        release {
            // TODO: Add your own signing config for the release build.
            // Signing with the debug keys for now, so `flutter run --release` works.
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

kotlin {
    compilerOptions {
        jvmTarget = JvmTarget.JVM_17
    }
}

flutter {
    source = "../.."
}

dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
}
