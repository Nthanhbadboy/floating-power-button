plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    // Must match AppGallery Connect package name.
    namespace = "com.nguyenminhthanh.power_volume"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }
    kotlinOptions { jvmTarget = JavaVersion.VERSION_17.toString() }

    defaultConfig {
        applicationId = "com.nguyenminhthanh.power_volume"
        minSdk = 24
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            // TODO: add your own signing config before uploading to
            // AppGallery (android/key.properties, never commit the keystore).
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter { source = "../.." }
