plugins {
    id("com.android.application")
    id("com.google.gms.google-services")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.aikido_kalamata_app"
    compileSdk = 35
    ndkVersion = "27.0.12077973"

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = "11"
    }

    defaultConfig {
        applicationId = "com.example.aikido_kalamata_app"
        minSdkVersion(23)
        targetSdkVersion(35)
        versionCode = flutter.versionCode
        versionName = flutter.versionName
        multiDexEnabled = true
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

dependencies {
    // --- ΑΝΑΒΑΘΜΙΣΗ ΚΑΙ ΠΡΟΣΘΗΚΗ ΓΙΑ FCM ---
    // Το Firebase BOM (Bill of Materials) διαχειρίζεται αυτόματα τις εκδόσεις όλων των Firebase βιβλιοθηκών
    implementation(platform("com.google.firebase:firebase-bom:33.1.1"))

    // Δηλώνουμε τις βιβλιοθήκες που θέλουμε, ΧΩΡΙΣ να ορίζουμε έκδοση
    implementation("com.google.firebase:firebase-analytics")
    implementation("com.google.firebase:firebase-auth")
    implementation("androidx.window:window:1.0.0")
    implementation("com.google.firebase:firebase-messaging") // Η προσθήκη για το Cloud Messaging
    // ----------------------------------------

    constraints {
        implementation("androidx.annotation:annotation:1.6.0") {
            because("Multiple libraries bring different versions of this, causing conflicts.")
        }
        implementation("androidx.annotation:annotation-experimental:1.3.0") {
            because("Multiple libraries bring different versions of this, causing conflicts.")
        }
    }
}

flutter {
    source = "../.."
}