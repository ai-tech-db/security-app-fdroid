# 🛡️ Security APP by AI-Tech-DB

Security APP is a modern, privacy-focused local VPN firewall and security monitor for Android.
Unlike commercial VPNs, it does not route your data to a remote server. It creates a local VPN tunnel directly on your device to intercept and filter traffic, ensuring maximum privacy.

Built with a powerful Kotlin core (VPN, DNS, Room) and a stunning Flutter UI, it protects your device against trackers, malicious domains, and suspicious apps.

## 🎬 Preview

https://github.com/user-attachments/assets/22d55705-7e8d-4a34-aeff-7ce5b1577b79

## ✨ Features

- Local VPN Firewall: Intercepts DNS queries and TLS SNI to block malicious, phishing, and tracking domains.
- Custom Blacklist: Manually block specific domains from the UI.
- Suspicious Apps Monitor: Scans installed apps and calculates a risk score based on dangerous permissions (Accessibility, Overlay, SMS).
- Recent Connections (Log): Real-time log of blocked/allowed connections with a configurable retention policy (OFF, 24h, 3 days).
- Battery Optimization Check: Guides the user to disable Android's aggressive battery saver, ensuring the VPN service stays alive.
- Modern UI: Dark, futuristic Flutter UI with custom animations (Welcome Screen, Setup).
- Lookalike Domain Shield: Detects domains that look like famous brands (e.g., g00gle.com).
- Exit & Stop: One-tap button to stop the VPN and completely close the app.

## 🛠️ Tech Stack

### Android (Kotlin)
- AGP 8.6.0 / Gradle 8.7
- Kotlin 2.1.10 / KSP 2.1.10-1.0.29
- Compose Compiler Plugin 2.1.10
- Room Database (Local storage for logs and rules)
- R8/ProGuard (Code shrinking)
- Local VPN Service (SentinelVpnService, DnsInterceptor, PacketEngine)

### Flutter (Dart)
- Flutter 3.35.7 / Dart 3.9.2
- Material 3 UI
- Battery Optimization Helper
- MethodChannel / EventChannel (Bridge between Flutter and Kotlin)

### Build Environment
- Docker (tacuns-dev container) for local development
- Android SDK 36 / Min SDK 29
- F-Droid build server for distribution

## 📂 Project Structure

    /
    ├── app/                    # Android native module (Kotlin)
    ├── security_ui/            # Flutter module (Dart)
    ├── gradle/                 # Gradle wrapper
    ├── build.gradle.kts        # Root Gradle build (Kotlin DSL)
    ├── settings.gradle.kts     # Gradle settings (repositories, plugins)
    ├── build.sh                # F-Droid build script
    ├── fastlane/               # App metadata (descriptions, screenshots, changelogs)
    ├── README.md
    ├── LICENSE
    └── .gitignore

## 🚀 Build & Run

### Prerequisites

- Docker installed on your host (for local development).
- Android SDK in /opt/android-sdk.
- Flutter SDK in /opt/flutter.
- A connected Android device (via USB) or emulator.

### Local Development (Docker)

Build the Flutter AAR (if you modify Dart code):

    docker exec -it -u root tacuns-dev bash -c '
    cd /security_ui
    flutter build aar --no-debug --no-profile
    '

Build the Android APK:

    docker exec -it -u root tacuns-dev bash -c '
    cd /app
    ./gradlew :app:assembleRelease --no-daemon
    '

The APK will be generated at: app/build/outputs/apk/release/app-release.apk

Install on device:

    docker exec -it -u root tacuns-dev bash -c '
    adb install -r /app/app/build/outputs/apk/release/app-release.apk
    '

### F-Droid Build

The F-Droid build is driven by build.sh, which is called from the F-Droid metadata (metadata/io.github.aitechdb.securityapp.yml in the fdroiddata repo).

build.sh does the following:

1. Sets up the Flutter SDK path and the CFUG mirrors (storage.flutter-io.cn, pub.flutter-io.cn) to avoid F-Droid network blocks.
2. Runs flutter build aar in security_ui/.
3. Copies the generated AARs to /tmp/flutter_aar/ for flatDir resolution.
4. Copies the Flutter engine .jar files from the Gradle cache to /tmp/flutter_aar/.
5. Moves security_ui/ to /tmp/security_ui_backup to avoid Gradle 8.7 "Project directory is not part of the build" errors.
6. Runs gradle :app:assembleRelease.

The F-Droid metadata declares:

    Builds:
      - versionName: 1.0.0
        versionCode: 2003
        commit: <hash>
        gradle:
          - yes
        output: app/build/outputs/apk/release/*.apk
        srclibs:
          - flutter@3.35.7
        build: bash build.sh $$flutter$$

### Updating the App

To publish a new version:

1. Increment versionCode and versionName in app/build.gradle.kts.
2. Commit and push to security-app-fdroid.
3. Update versionCode, versionName, and commit: in the F-Droid metadata.
4. Push the metadata to the fdroiddata repo.
5. F-Droid will rebuild automatically.

## 🔒 Security & Privacy

All filtering happens locally on your device. No data is sent to remote servers.

The VPN service uses a foreground notification to stay alive.

The app requests only the necessary permissions (BIND_VPN_SERVICE, FOREGROUND_SERVICE, etc.).

## 🧪 Testing & Verification

Check VPN service logs: adb logcat -s DnsInterceptor:D *:S

Note on testing the firewall: Browsers and operating systems cache DNS records and web pages aggressively. If you add a domain to the blacklist and it still loads, try using an Incognito/Private window or clear your browser and DNS cache. The firewall operates at the network level; if the browser uses a cached IP, it may bypass the initial DNS interception.

Log retention: To view connection logs, you must enable a retention period (24 hours or 3 days) from the Settings screen. If set to OFF, logs are not displayed. To completely remove all stored logs, set the option to OFF and close the app.

Verify VPN process: adb shell ps -A | grep tacu

Check VPN permission: adb shell dumpsys package com.tacu.nsfwzerotrust | grep BIND_VPN_SERVICE

## 📝 Notes

- If you modify Dart code, you MUST regenerate the Flutter AAR and rebuild the Android app.
- The Gradle cache for F-Droid is in .gradle-cache/ (set via GRADLE_USER_HOME).
- The build uses local.properties with sdk.dir and flutter.sdk.
- app/proguard-rules.pro contains -dontwarn rules for Flutter plugins referenced by GeneratedPluginRegistrant. Without these, R8 fails in release mode.

## 📄 License & Attribution

This project is licensed under the GNU General Public License v3.0 (GPLv3). See the LICENSE file for details.

**What we built (AI-Tech-DB)**
The Flutter-based user interface (Welcome Screen, Setup, Dashboard, Log, Settings), the native Android bridge (MainActivity.kt, MethodChannels), and all the integration logic were designed and written from scratch by AI-Tech-DB.

**What is derived (TacUNS)**
The core firewall engine is based on the original TacUNS project, which was licensed under the Apache License 2.0. The original Apache 2.0 code has been modified and integrated into this GPLv3 project. See the NOTICE file for full attribution details.

## 📱 Follow Us & Full Video

- **Full Video Tutorial (Facebook)**: [Watch the full demo on Facebook](https://fb.watch/v/4Tdu1ufpW/)

---

Made with ❤️ by AI-Tech-DB
