#!/usr/bin/env bash
set -euo pipefail

cd "${BUILD_WORKSPACE_DIRECTORY:-$(git rev-parse --show-toplevel)}"

export PATH="$(go env GOPATH)/bin:${HOME}/.swiftly/bin:${PATH}"

gofmt -w apps/api
goimports -w apps/api

swift format --in-place --recursive packages apps/ios

cd apps/android
./gradlew spotlessApply
cd ../..

find . \
    \( -path "./.git" -o -path "./out" -o -path "./packages/*/.build" -o -path "./apps/android/.gradle" -o -path "./apps/android/*/build" \) -prune \
    -o \( -name "BUILD" -o -name "BUILD.bazel" -o -name "MODULE.bazel" -o -name "*.bzl" \) -print0 |
    xargs -0 buildifier
