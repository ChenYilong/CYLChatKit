#!/bin/sh
# Usage: scripts/pod-lint.sh [extra pod lib lint arguments]
#
# Runs `pod lib lint` on CYLChatKit.podspec (docs/ci.md). Adapted from CYLTabBarController's scripts/pod-lint.sh.
# The legacy sources still produce many warnings, so --allow-warnings is passed; errors fail the lint.
set -e
cd "$(dirname "$0")/.."
export XCODE_XCCONFIG_FILE="$PWD/scripts/pod-lint.xcconfig"
pod lib lint CYLChatKit.podspec --allow-warnings --skip-tests "$@"
