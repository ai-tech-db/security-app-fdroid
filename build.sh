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

# Crea un settings temporaneo che dichiara resolve_dependencies come build file root
TMPDIR=$(mktemp -d)
trap 'rm -rf "$TMPDIR"' EXIT
cat > "$TMPDIR/settings.gradle.kts" <<EMPTYSETTINGS
rootProject.name = "resolve-dependencies"
rootProject.buildFileName = "$RESOLVE_SCRIPT"
EMPTYSETTINGS

echo "===== RESOLVING FLUTTER DEPENDENCIES ====="

# Esegui da PROJECT_DIR (gradlew-fdroid trova la versione) con settings che dichiara il build file
(
    cd "$PROJECT_DIR"
    gradle \
        --settings-file "$TMPDIR/settings.gradle.kts" \
        resolveDependencies \
        --no-daemon
)

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
