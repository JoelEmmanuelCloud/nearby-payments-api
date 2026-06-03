#!/usr/bin/env bash
set -euo pipefail

ROOT="${BUILD_WORKSPACE_DIRECTORY:-}"
if [[ -z "${ROOT}" ]]; then
  ROOT="$(git rev-parse --show-toplevel)"
fi

ANDROID_ROOT="${ROOT}/apps/android"
ENV="${ANDROID_ROOT}/.env"

if [[ "${CI:-}" != "true" && -f "${ENV}" ]]; then
  export $(cat ${ENV} | xargs)
fi

SWIFT_SDK_BUNDLE="${SWIFT_SDK_PATH}/swift-${SWIFT_ANDROID_SDK_VERSION}.artifactbundle"
NDK_SYSROOT="${SWIFT_SDK_BUNDLE}/swift-android/ndk-sysroot/usr/include"

if [[ ! -d "${NDK_SYSROOT}" ]]; then
  if [[ ! -x "${SWIFT_SDK_BUNDLE}/swift-android/scripts/setup-android-sdk.sh" ]]; then
    echo "Swift Android SDK setup script not found: ${SWIFT_SDK_BUNDLE}/swift-android/scripts/setup-android-sdk.sh" >&2
    exit 1
  fi

  ANDROID_NDK_HOME="${ANDROID_NDK_HOME}" \
    "${SWIFT_SDK_BUNDLE}/swift-android/scripts/setup-android-sdk.sh"
fi

# --- Share the Gradle distribution cache with the swift-java plugin ---------
#
# The swift-java JExtract plugin forces its own GRADLE_USER_HOME
# (~/.cache/swift-java/gradle) so its nested Gradle build can't clobber the
# outer one. The downside is that each callback-enabled package (auth, hsm,
# storage) otherwise downloads the full ~130MB Gradle distribution into that
# isolated home — in parallel — which both wastes bandwidth and races for the
# same dist lock (the "Timeout reached waiting for exclusive access" error).
#
# Point the plugin home's `wrapper/dists` at the global `~/.gradle` dist cache
# via a symlink. This is version-agnostic (any Gradle version the global cache
# holds is shared automatically), avoids duplicating the unpacked distribution,
# and collapses the N separate dist caches into one — so it's downloaded at most
# once and reused by every package and the outer Android build, locally and CI.
SWIFT_JAVA_GRADLE_HOME="${HOME}/.cache/swift-java/gradle"
GLOBAL_GRADLE_DISTS="${GRADLE_USER_HOME:-${HOME}/.gradle}/wrapper/dists"
mkdir -p "${SWIFT_JAVA_GRADLE_HOME}/wrapper" "${GLOBAL_GRADLE_DISTS}"
if [[ ! -L "${SWIFT_JAVA_GRADLE_HOME}/wrapper/dists" ]]; then
  rm -rf "${SWIFT_JAVA_GRADLE_HOME}/wrapper/dists"
  ln -s "${GLOBAL_GRADLE_DISTS}" "${SWIFT_JAVA_GRADLE_HOME}/wrapper/dists"
fi

cd "${ANDROID_ROOT}"
./gradlew ${NEARBY_ANDROID_GRADLE_TASKS:-:bridge:assembleDebug}
