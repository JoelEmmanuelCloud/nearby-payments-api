"""Shared Bazel constants and macros for the Nearby monorepo."""

GO_VERSION = "1.25.3"

# Root under which each callback package's isolated Gradle user home lives.
# Tilde-expanded by the seeding script. Per-package subdir is appended.
JAVA_CALLBACK_GRADLE_HOME_ROOT = "~/.cache/swift-java/gradle"
