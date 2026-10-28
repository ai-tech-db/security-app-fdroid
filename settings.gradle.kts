pluginManagement {
    val flutterSdkPath = run {
        val properties = java.util.Properties()
        file("local.properties").inputStream().use { properties.load(it) }
        val path = properties.getProperty("flutter.sdk")
        require(path != null) { "flutter.sdk not set in local.properties" }
        path
    }

    includeBuild("$flutterSdkPath/packages/flutter_tools/gradle")

    repositories {
        google()
        mavenCentral()
        flatDir {
            dirs("/tmp/flutter_aar")
        }
        gradlePluginPortal()
    }

    plugins {
        id("com.android.application") version "8.6.0"
        id("com.android.library") version "8.6.0"
        id("org.jetbrains.kotlin.android") version "2.1.10"
        id("com.google.devtools.ksp") version "2.1.10-1.0.29"
    }
}

dependencyResolutionManagement {
    repositoriesMode.set(RepositoriesMode.PREFER_SETTINGS)
    repositories {
        google()
        mavenCentral()
        // Repository ufficiale degli artefatti del motore Flutter
        maven("https://storage.googleapis.com/download.flutter.io")
    }
}

rootProject.name = "TacUNS"
include(":app")
apply(from = file("security_ui/.android/include_flutter.groovy"))
