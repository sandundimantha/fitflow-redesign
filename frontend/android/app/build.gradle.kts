import java.util.Properties
import java.io.FileInputStream

plugins {
    id("com.android.application")
    id("dev.flutter.flutter-gradle-plugin")
}

val keystoreProperties = Properties()
val keystorePropertiesFile = rootProject.file("key.properties")
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(FileInputStream(keystorePropertiesFile))
}

android {
    namespace = "com.fitflow.frontend"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    signingConfigs {
        create("release") {
            val keyAliasVal = keystoreProperties.getProperty("keyAlias")
            val keyPasswordVal = keystoreProperties.getProperty("keyPassword")
            val storeFileVal = keystoreProperties.getProperty("storeFile")
            val storePasswordVal = keystoreProperties.getProperty("storePassword")

            if (storeFileVal != null) {
                val candidate1 = file(storeFileVal)
                val candidate2 = file("upload-keystore.jks")
                val candidate3 = rootProject.file(storeFileVal)
                val candidate4 = rootProject.file("app/$storeFileVal")

                val resolvedFile = when {
                    candidate1.exists() -> candidate1
                    candidate2.exists() -> candidate2
                    candidate3.exists() -> candidate3
                    candidate4.exists() -> candidate4
                    else -> null
                }

                if (resolvedFile != null) {
                    keyAlias = keyAliasVal
                    keyPassword = keyPasswordVal
                    storeFile = resolvedFile
                    storePassword = storePasswordVal
                }
            }
        }
    }

    defaultConfig {
        applicationId = "com.fitflow.frontend"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            val releaseSigning = signingConfigs.getByName("release")
            signingConfig = if (releaseSigning.storeFile != null && releaseSigning.storeFile!!.exists()) {
                releaseSigning
            } else {
                signingConfigs.getByName("debug")
            }
        }
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
