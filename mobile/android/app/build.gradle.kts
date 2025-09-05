plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.lissan_ai"

    compileSdk = (project.findProperty("flutter.compileSdkVersion") ?: 36).toString().toInt()
    ndkVersion = "27.0.12077973"

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        applicationId = "com.example.lissan_ai"

        minSdk = (project.findProperty("flutter.minSdkVersion") ?: 24).toString().toInt()
        targetSdk = (project.findProperty("flutter.targetSdkVersion") ?: 36).toString().toInt()

        versionCode = (project.findProperty("flutter.versionCode") ?: 1).toString().toInt()
        versionName = (project.findProperty("flutter.versionName") ?: "1.0.0").toString()
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}
