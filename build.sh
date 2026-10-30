#!/bin/bash
set -e

FLUTTER_SDK="$1"
if [ -z "$FLUTTER_SDK" ] || [ ! -d "$FLUTTER_SDK" ]; then
    echo "ERRORE: Percorso Flutter non valido: '$FLUTTER_SDK'"
    exit 1
fi

export PATH="$FLUTTER_SDK/bin:$PATH"
export FLUTTER_STORAGE_BASE_URL="https://storage.flutter-io.cn"
export PUB_HOSTED_URL="https://pub.flutter-io.cn"

echo "sdk.dir=$ANDROID_SDK_ROOT" > local.properties
echo "flutter.sdk=$FLUTTER_SDK" >> local.properties

# USA SOLO lo script Groovy (.gradle). Il .kts ha un bug di nullability in Flutter 3.35.7.
RESOLVE_SCRIPT="$FLUTTER_SDK/packages/flutter_tools/gradle/resolve_dependencies.gradle"
if [ ! -f "$RESOLVE_SCRIPT" ]; then
    echo "ERRORE: resolve_dependencies.gradle (Groovy) non trovato."
    echo "Il file .kts è buggato in questa versione di Flutter. Serve il .gradle."
    exit 1
fi

echo "Uso: $RESOLVE_SCRIPT"
gradle -b "$RESOLVE_SCRIPT" resolveDependencies --no-daemon

(cd security_ui && flutter pub get && flutter build aar --no-debug --no-profile)
mkdir -p /tmp/flutter_aar
find security_ui/build -name "*.aar" -exec cp {} /tmp/flutter_aar/ \;
mv security_ui /tmp/security_ui_backup
gradle :app:assembleRelease --no-daemon
