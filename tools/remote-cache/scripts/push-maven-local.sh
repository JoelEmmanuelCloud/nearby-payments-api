#!/usr/bin/env bash
set -euo pipefail

ROOT="${ROOT:-$(cd "$(dirname "${BASH_SOURCE[0]}")/../../.." && pwd)}"
ENV_FILE="${ENV_FILE:-${ROOT}/.env}"
MAVEN_ROOT="${MAVEN_ROOT:-${HOME}/.m2/repository}"
MAVEN_GROUP_PATH="${MAVEN_GROUP_PATH:-org/swift/swiftkit}"
R2_BUCKET="${R2_BUCKET:-nearby-bazel-cache}"
R2_PREFIX="${R2_PREFIX:-maven}"
WRANGLER=(npx --prefix "${ROOT}/tools/remote-cache" wrangler)

if [[ -f "${ENV_FILE}" ]]; then
    set -a
    # shellcheck disable=SC1090
    source "${ENV_FILE}"
    set +a
fi

if [[ ! -d "${MAVEN_ROOT}/${MAVEN_GROUP_PATH}" ]]; then
    echo "Maven path not found: ${MAVEN_ROOT}/${MAVEN_GROUP_PATH}" >&2
    exit 1
fi

cd "${MAVEN_ROOT}"

find "${MAVEN_GROUP_PATH}" -type f \
    ! -name "*.md5" \
    ! -name "*.sha1" \
    -print0 | while IFS= read -r -d "" file; do
    key="${R2_PREFIX}/${file}"
    "${WRANGLER[@]}" r2 object put "${R2_BUCKET}/${key}" --file "${file}" --remote

    # generate and upload checksums
    md5 -q "${file}" | tr -d '\n' > /tmp/checksum.tmp
    "${WRANGLER[@]}" r2 object put "${R2_BUCKET}/${key}.md5" --file /tmp/checksum.tmp --remote

    shasum -a 1 "${file}" | awk '{print $1}' | tr -d '\n' > /tmp/checksum.tmp
    "${WRANGLER[@]}" r2 object put "${R2_BUCKET}/${key}.sha1" --file /tmp/checksum.tmp --remote

    if [[ "$(basename "${file}")" == "maven-metadata-local.xml" ]]; then
        remote_metadata="${key%/maven-metadata-local.xml}/maven-metadata.xml"
        "${WRANGLER[@]}" r2 object put "${R2_BUCKET}/${remote_metadata}" --file "${file}" --remote
    fi
done
