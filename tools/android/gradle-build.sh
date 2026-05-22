#!/usr/bin/env bash
set -euo pipefail

ROOT="${BUILD_WORKSPACE_DIRECTORY:-}"
if [[ -z "${ROOT}" ]]; then
  ROOT="$(git rev-parse --show-toplevel)"
fi

ANDROID_ROOT="${ROOT}/apps/android"
BRIDGE_ROOT="${ANDROID_ROOT}/bridge"
PROPERTIES_TEMPLATE="${BRIDGE_ROOT}/gradle.properties.tmpl"
PROPERTIES_FILE="${BRIDGE_ROOT}/gradle.properties"

required_file() {
  local label="$1"
  local path="$2"

  if [[ ! -f "${path}" ]]; then
    echo "${label} not found: ${path}" >&2
    exit 1
  fi
}

required_dir() {
  local label="$1"
  local path="$2"

  if [[ ! -d "${path}" ]]; then
    echo "${label} not found: ${path}" >&2
    exit 1
  fi
}

resolve_swiftly() {
  if [[ -n "${SWIFTLY_PATH:-}" ]]; then
    echo "${SWIFTLY_PATH}"
    return
  fi

  if command -v swiftly >/dev/null 2>&1; then
    command -v swiftly
    return
  fi

  if [[ -x "${HOME}/.swiftly/bin/swiftly" ]]; then
    echo "${HOME}/.swiftly/bin/swiftly"
    return
  fi

  echo "swiftly not found. Set SWIFTLY_PATH or install swiftly." >&2
  exit 1
}

resolve_swift_sdk_root() {
  if [[ -n "${SWIFT_SDK_PATH:-}" ]]; then
    echo "${SWIFT_SDK_PATH}"
    return
  fi

  if [[ -d "${HOME}/Library/org.swift.swiftpm/swift-sdks" ]]; then
    echo "${HOME}/Library/org.swift.swiftpm/swift-sdks"
    return
  fi

  if [[ -d "${HOME}/.swiftpm/swift-sdks" ]]; then
    echo "${HOME}/.swiftpm/swift-sdks"
    return
  fi

  echo "Swift SDK root not found. Set SWIFT_SDK_PATH." >&2
  exit 1
}

resolve_android_ndk_home() {
  if [[ -n "${ANDROID_NDK_HOME:-}" && -d "${ANDROID_NDK_HOME}" ]]; then
    echo "${ANDROID_NDK_HOME}"
    return
  fi

  local sdk_root="${ANDROID_SDK_ROOT:-${ANDROID_HOME:-}}"
  if [[ -z "${sdk_root}" && -d "${HOME}/Library/Android/sdk" ]]; then
    sdk_root="${HOME}/Library/Android/sdk"
  fi

  if [[ -n "${sdk_root}" && -d "${sdk_root}/ndk" ]]; then
    find "${sdk_root}/ndk" -mindepth 1 -maxdepth 1 -type d | sort | tail -n 1
    return
  fi

  echo "Android NDK not found. Set ANDROID_NDK_HOME, ANDROID_SDK_ROOT, or ANDROID_HOME." >&2
  exit 1
}

ensure_ndk_sysroot() {
  local sdk_bundle="$1"
  local ndk_home="$2"
  local ndk_sysroot="${sdk_bundle}/swift-android/ndk-sysroot"

  if [[ -d "${ndk_sysroot}/usr/include" ]]; then
    return
  fi

  local setup_script="${sdk_bundle}/swift-android/scripts/setup-android-sdk.sh"
  required_file "Swift Android SDK setup script" "${setup_script}"

  echo "Swift Android ndk-sysroot missing; running SDK setup script." >&2
  ANDROID_NDK_HOME="${ndk_home}" "${setup_script}"

  required_dir "Swift Android ndk-sysroot" "${ndk_sysroot}/usr/include"
}

write_gradle_properties() {
  local swiftly_path="$1"
  local swift_sdk_path="$2"
  local swift_version="$3"
  local swift_android_sdk_version="$4"

  required_file "Gradle properties template" "${PROPERTIES_TEMPLATE}"

  sed \
    -e "s|{SWIFTLY_PATH}|${swiftly_path}|g" \
    -e "s|{SWIFT_SDK_PATH}|${swift_sdk_path}|g" \
    -e "s|{SWIFT_VERSION}|${swift_version}|g" \
    -e "s|{SWIFT_ANDROID_SDK_VERSION}|${swift_android_sdk_version}|g" \
    "${PROPERTIES_TEMPLATE}" > "${PROPERTIES_FILE}"
}

SWIFTLY_BIN="$(resolve_swiftly)"
SWIFT_SDK_ROOT="$(resolve_swift_sdk_root)"
SWIFT_VERSION="${SWIFT_VERSION:-6.3}"
SWIFT_ANDROID_SDK_VERSION="${SWIFT_ANDROID_SDK_VERSION:-${SWIFT_VERSION}-RELEASE_android}"
SWIFT_SDK_BUNDLE="${SWIFT_SDK_ROOT}/swift-${SWIFT_ANDROID_SDK_VERSION}.artifactbundle"
ANDROID_NDK_HOME_RESOLVED="$(resolve_android_ndk_home)"

required_file "swiftly" "${SWIFTLY_BIN}"
required_dir "Swift Android SDK bundle" "${SWIFT_SDK_BUNDLE}"
ensure_ndk_sysroot "${SWIFT_SDK_BUNDLE}" "${ANDROID_NDK_HOME_RESOLVED}"
write_gradle_properties "${SWIFTLY_BIN}" "${SWIFT_SDK_ROOT}" "${SWIFT_VERSION}" "${SWIFT_ANDROID_SDK_VERSION}"

cd "${ANDROID_ROOT}"
./gradlew ${NEARBY_ANDROID_GRADLE_TASKS:-:bridge:assembleDebug}
