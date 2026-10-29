#!/bin/bash
set -e
export PATH="$1/bin:$PATH"
export FLUTTER_STORAGE_BASE_URL="https://mirrors.nju.edu.cn/flutter"
export PUB_HOSTED_URL="https://mirrors.nju.edu.cn/dart-pub"
echo "sdk.dir=$ANDROID_SDK_ROOT" > local.properties
echo "flutter.sdk=$1" >> local.properties
(cd security_ui && flutter pub get && flutter build aar --no-debug --no-profile)
mkdir -p /tmp/flutter_aar
find security_ui/build -name "*.aar" -exec cp {} /tmp/flutter_aar/ \;
gradle :app:assembleRelease --no-daemon
