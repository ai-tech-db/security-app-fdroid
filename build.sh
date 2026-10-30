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

echo "sdk.dir=$ANDROID_SDK_ROOT" > local.properties
echo "flutter.sdk=$FLUTTER_SDK" >> local.properties

flutter --version

RESOLVE_SCRIPT="$FLUTTER_SDK/packages/flutter_tools/gradle/resolve_dependencies.gradle.kts"
if [ ! -f "$RESOLVE_SCRIPT" ]; then
    echo "ERRORE: resolve_dependencies.gradle.kts non trovato."
    exit 1
fi

sed -i 's/flutterRoot\.isDirectory/flutterRoot!!.isDirectory/g' "$RESOLVE_SCRIPT"
sed -i 's/flutterRoot\.absolutePath/flutterRoot!!.absolutePath/g' "$RESOLVE_SCRIPT"

echo "===== RESOLVING FLUTTER DEPENDENCIES ====="
gradle -b "$RESOLVE_SCRIPT" resolveDependencies --no-daemon

echo "===== BUILDING FLUTTER AAR ====="
cd "$PROJECT_DIR/security_ui"
flutter pub get
flutter build aar --no-debug --no-profile

mkdir -p /tmp/flutter_aar
find build -name "*.aar" -exec cp {} /tmp/flutter_aar/ \;

mv "$PROJECT_DIR/security_ui" /tmp/security_ui_backup

echo "===== BUILDING ANDROID RELEASE ====="
cd "$PROJECT_DIR"
gradle :app:assembleRelease --no-daemon

echo "===== BUILD COMPLETED ====="
