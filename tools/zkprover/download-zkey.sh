#!/bin/sh
# Download the zkLogin main proving key (~1GB) to zkeys/zkLogin-main.zkey.
#
# POSIX sh, no bashisms — runs the same under bash/zsh/fish/dash (it's invoked via this shebang
# regardless of your interactive shell). The key ships as a Git LFS object in the sui-foundation
# ceremony repo, so the real dependencies are `git` + `git-lfs` (not wget/curl).
set -eu

OUT_DIR="zkeys"
OUT_FILE="$OUT_DIR/zkLogin-main.zkey"
REPO="https://github.com/sui-foundation/zklogin-ceremony-contributions.git"

# Idempotent: skip if already downloaded.
if [ -f "$OUT_FILE" ]; then
  echo "Already present: $OUT_FILE"
  exit 0
fi

# Dependencies.
if ! command -v git >/dev/null 2>&1; then
  echo "error: git is required" >&2
  exit 1
fi
if ! git lfs version >/dev/null 2>&1; then
  echo "error: git-lfs is required — install from https://git-lfs.com" >&2
  exit 1
fi

mkdir -p "$OUT_DIR"

# Shallow-clone without fetching LFS blobs, then pull only the zkey, then move it out and clean up.
TMP_DIR="$(mktemp -d)"
trap 'rm -rf "$TMP_DIR"' EXIT INT TERM

GIT_LFS_SKIP_SMUDGE=1 git clone --depth 1 "$REPO" "$TMP_DIR/repo"
(cd "$TMP_DIR/repo" && git lfs pull --include "zkLogin-main.zkey")

mv "$TMP_DIR/repo/zkLogin-main.zkey" "$OUT_FILE"
echo "Downloaded: $OUT_FILE"
