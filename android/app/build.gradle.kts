plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.crispstrobe.crisp_math"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    defaultConfig {
        applicationId = "com.crispstrobe.crisp_math"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        create("release") {
            val props = java.util.Properties()
            val propsFile = rootProject.file("key.properties")
            if (propsFile.exists()) {
                props.load(propsFile.inputStream())
                storeFile = file(props["storeFile"] as String)
                storePassword = props["storePassword"] as String
                keyAlias = props["keyAlias"] as String
                keyPassword = props["keyPassword"] as String
            }
        }
    }

    buildTypes {
        release {
            val propsFile = rootProject.file("key.properties")
            signingConfig = if (propsFile.exists()) {
                signingConfigs.getByName("release")
            } else {
                // Fall back to debug signing when key.properties is absent
                // (CI builds, local dev). Play Store uploads require release signing.
                signingConfigs.getByName("debug")
            }
        }
    }
}

flutter {
    source = "../.."
}
