import java.io.FileInputStream
import java.util.Properties

plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
}

// Release signing (for publishing):
// - Reads android/key.properties when present (local release, or created
//   temporarily by the "Build RELEASE (publish)" GitHub Actions workflow
//   from repository Secrets — the keystore is NEVER committed).
// - Falls back to the debug key only when key.properties is absent, so
//   local debug/test builds keep working. The release workflow refuses
//   to publish a debug-signed build (it verifies the certificate).
val keystoreProperties = Properties()
val keystorePropertiesFile = rootProject.file("key.properties")
val hasReleaseSigning = keystorePropertiesFile.exists()
if (hasReleaseSigning) {
    keystoreProperties.load(FileInputStream(keystorePropertiesFile))
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

    signingConfigs {
        create("release") {
            if (hasReleaseSigning) {
                keyAlias = keystoreProperties.getProperty("keyAlias")
                keyPassword = keystoreProperties.getProperty("keyPassword")
                storeFile = keystoreProperties.getProperty("storeFile")?.let { file(it) }
                storePassword = keystoreProperties.getProperty("storePassword")
            }
        }
    }

    buildTypes {
        release {
            signingConfig = if (hasReleaseSigning) {
                signingConfigs.getByName("release")
            } else {
                // Local/test builds only — CI publishes require key.properties.
                signingConfigs.getByName("debug")
            }
        }
    }
}

dependencies {
    // Huawei Petal Ads (banner) — attempted first on HMS devices.
    implementation("com.huawei.hms:ads-lite:13.4.69.300")
}

flutter { source = "../.." }
