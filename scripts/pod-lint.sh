#!/bin/bash
# Usage: scripts/pod-lint.sh [extra pod lib lint arguments]
#
# Runs `pod lib lint` on CYLChatKit.podspec (docs/ci.md). Adapted from CYLTabBarController's scripts/pod-lint.sh.
# The legacy sources still produce many warnings, so --allow-warnings is passed; errors fail the lint.
#
# CYLTableViewPlaceHolder is used from a git commit (see ChatKit-OC/Podfile), not from trunk. The lint takes the
# same commit: it checks that commit out and passes its podspec with --include-podspecs, so the sources resolve
# from the checkout.
set -euo pipefail
cd "$(dirname "$0")/.."
export XCODE_XCCONFIG_FILE="$PWD/scripts/pod-lint.xcconfig"

COMMIT=$(awk '/^CHECKOUT OPTIONS:/{f=1} f && /CYLTableViewPlaceHolder:/{g=1} g && /:commit:/{print $2; exit}' ChatKit-OC/Podfile.lock)
EXTRA=()
if [[ -n "$COMMIT" ]]; then
    WORK="$PWD/build/lint-podspecs"
    rm -rf "$WORK" && mkdir -p "$WORK"
    git clone --quiet --filter=blob:none https://github.com/ChenYilong/CYLTableViewPlaceHolder.git "$WORK/CYLTableViewPlaceHolder"
    git -C "$WORK/CYLTableViewPlaceHolder" checkout --quiet "$COMMIT"
    echo "Linting with CYLTableViewPlaceHolder at $COMMIT"
    EXTRA+=(--include-podspecs="$WORK/CYLTableViewPlaceHolder/CYLTableViewPlaceHolder.podspec")
fi

pod lib lint CYLChatKit.podspec --allow-warnings --skip-tests ${EXTRA[@]+"${EXTRA[@]}"} "$@"
