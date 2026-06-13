#!/usr/bin/env bash
set -euo pipefail

mode="${1:-format}"
root="${BUILD_WORKSPACE_DIRECTORY:-$(git rev-parse --show-toplevel)}"
ktlint_version="1.5.0"
ktlint_bin="${root}/out/tools/ktlint-${ktlint_version}"
ktlint_editorconfig="${root}/out/tools/package-ktlint.editorconfig"

mkdir -p "$(dirname "${ktlint_bin}")"

if [[ ! -x "${ktlint_bin}" ]]; then
    curl -fsSL \
        "https://github.com/pinterest/ktlint/releases/download/${ktlint_version}/ktlint" \
        -o "${ktlint_bin}"
    chmod +x "${ktlint_bin}"
fi

cat >"${ktlint_editorconfig}" <<'EOF'
root = true

[*.{kt,kts}]
ktlint_function_naming_ignore_when_annotated_with = Composable
ktlint_standard_property-naming = disabled
EOF

files_list="$(mktemp)"
trap 'rm -f "${files_list}"' EXIT

find "${root}/packages" \
    \( -path "*/.build/*" -o -path "*/build/*" \) -prune \
    -o -name "*.kt" -print >"${files_list}"

if [[ ! -s "${files_list}" ]]; then
    exit 0
fi

case "${mode}" in
    format)
        xargs "${ktlint_bin}" --editorconfig="${ktlint_editorconfig}" --format <"${files_list}"
        ;;
    check)
        xargs "${ktlint_bin}" --editorconfig="${ktlint_editorconfig}" <"${files_list}"
        ;;
    *)
        echo "usage: $0 [format|check]" >&2
        exit 2
        ;;
esac
