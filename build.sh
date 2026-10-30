echo "===== BUILDING FLUTTER AAR ====="
cd "$PROJECT_DIR/security_ui"
flutter pub get
flutter build aar --no-debug --no-profile

mkdir -p /tmp/flutter_aar
find build -name "*.aar" -exec cp {} /tmp/flutter_aar/ \;

# Copia i .jar del motore dalla cache Gradle in /tmp/flutter_aar/
# con i nomi che flatDir cerca
FLUTTER_ENGINE_HASH="035316565ad77281a75305515e4682e6c4c6f7ca"
for ARTIFACT in flutter_embedding_release armeabi_v7a_release arm64_v8a_release x86_64_release; do
    JAR_PATH=$(find "$GRADLE_USER_HOME/caches/modules-2/files-2.1/io.flutter/$ARTIFACT" -name "*.jar" 2>/dev/null | head -1)
    if [ -n "$JAR_PATH" ]; then
        cp "$JAR_PATH" "/tmp/flutter_aar/$ARTIFACT-$FLUTTER_ENGINE_HASH.jar"
        cp "$JAR_PATH" "/tmp/flutter_aar/$ARTIFACT.jar"
    fi
done
