#!/bin/bash
set -e

FLUTTER_SDK="$1"
if [ -z "$FLUTTER_SDK" ] || [ ! -d "$FLUTTER_SDK" ]; then
    echo "ERRORE: Percorso Flutter non valido: '$FLUTTER_SDK'"
    exit 1
fi

cd "$(dirname "$0")"
PROJECT_DIR="$(pwd)"

export PATH="$FLUTTER_SDK/bin:$PATH"
export FLUTTER_STORAGE_BASE_URL="https://storage.flutter-io.cn"
export PUB_HOSTED_URL="https://pub.flutter-io.cn"
export GRADLE_USER_HOME="$PROJECT_DIR/.gradle-cache"

echo "sdk.dir=$ANDROID_SDK_ROOT" > local.properties
echo "flutter.sdk=$FLUTTER_SDK" >> local.properties

flutter --version

echo "===== BUILDING FLUTTER AAR ====="
cd "$PROJECT_DIR/security_ui"
flutter pub get
flutter build aar --no-debug --no-profile

mkdir -p /tmp/flutter_aar
find build -name "*.aar" -exec cp {} /tmp/flutter_aar/ \;

# Copia i .jar del motore dalla cache Gradle in /tmp/flutter_aar/
FLUTTER_ENGINE_HASH="035316565ad77281a75305515e4682e6c4c6f7ca"
for ARTIFACT in flutter_embedding_release armeabi_v7a_release arm64_v8a_release x86_64_release; do
    JAR_PATH=$(find "$GRADLE_USER_HOME/caches/modules-2/files-2.1/io.flutter/$ARTIFACT" -name "*.jar" 2>/dev/null | head -1)
    if [ -n "$JAR_PATH" ]; then
        cp "$JAR_PATH" "/tmp/flutter_aar/$ARTIFACT-$FLUTTER_ENGINE_HASH.jar"
        cp "$JAR_PATH" "/tmp/flutter_aar/$ARTIFACT.jar"
    fi
done

mv "$PROJECT_DIR/security_ui" /tmp/security_ui_backup

echo "===== BUILDING ANDROID RELEASE ====="
cd "$PROJECT_DIR"
gradle :app:assembleRelease --no-daemon

echo "===== BUILD COMPLETED ====="
