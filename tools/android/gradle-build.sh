#!/usr/bin/env bash
set -euo pipefail

ROOT="${BUILD_WORKSPACE_DIRECTORY:-}"
if [[ -z "${ROOT}" ]]; then
  ROOT="$(git rev-parse --show-toplevel)"
fi

ANDROID_ROOT="${ROOT}/apps/android"
SWIFT_SDK_BUNDLE="${SWIFT_SDK_PATH}/swift-${SWIFT_ANDROID_SDK_VERSION}.artifactbundle"
NDK_SYSROOT="${SWIFT_SDK_BUNDLE}/swift-android/ndk-sysroot/usr/include"

if [[ ! -d "${NDK_SYSROOT}" ]]; then
  ANDROID_NDK_HOME="${ANDROID_NDK_HOME}" \
    "${SWIFT_SDK_BUNDLE}/swift-android/scripts/setup-android-sdk.sh"
fi

cd "${ANDROID_ROOT}"
./gradlew ${NEARBY_ANDROID_GRADLE_TASKS:-:bridge:assembleDebug}
