#!/bin/bash
# Usage: scripts/demo-screenshots.sh [output folder]     (default: build/screenshots)
#
# CI helper (docs/ci.md), adapted from CYLTabBarController's scripts/theme-screenshots.sh: builds the ChatKit-OC
# demo for an iPhone simulator, launches it, and takes one screenshot per screen:
#   login          - the normal launch screen
#   conversations  - `-LCCKDemoScreen conversations`: the tab bar UI without a LeanCloud login
#   chat           - `-LCCKDemoScreen chat`: a conversation view pushed on the first tab
# Each screenshot is also printed as base64 JPEG between markers, so it can be recovered from the job log.
set -euo pipefail

cd "$(dirname "$0")/.."
ROOT="$PWD"
OUT="${1:-$ROOT/build/screenshots}"
mkdir -p "$OUT"
DERIVED="$ROOT/build/DerivedData/screenshots"

DEVICE_ID=$(xcrun simctl list devices available -j | /usr/bin/python3 -c '
import json, sys
devices = json.load(sys.stdin)["devices"]
best = None
for runtime, items in devices.items():
    if "iOS" not in runtime:
        continue
    for d in items:
        if d.get("isAvailable") and d["name"].startswith("iPhone"):
            version = tuple(int(x) for x in runtime.rsplit("iOS-", 1)[-1].split("-") if x.isdigit())
            key = (version, "Pro" not in d["name"] and "Plus" not in d["name"] and "Max" not in d["name"], d["name"])
            if best is None or key > best[0]:
                best = (key, d["udid"], d["name"], runtime)
if best:
    print(best[1]); print(best[2] + " (" + best[3].rsplit(".", 1)[-1] + ")", file=sys.stderr)
')
if [[ -z "$DEVICE_ID" ]]; then
    echo "error: no available iPhone simulator" >&2
    exit 1
fi

# The vendored lame.framework has no arm64 simulator slice, so the app is built for x86_64 and runs under Rosetta on
# Apple silicon runners (CYLChatKit.podspec excludes arm64 for simulator builds).
if [[ "$(uname -m)" == "arm64" ]] && ! /usr/bin/pgrep -q oahd; then
    sudo softwareupdate --install-rosetta --agree-to-license || true
fi

cd ChatKit-OC
# Pods/ is partly committed, so always install (the Podfile is not changed).
pod install --repo-update
xcodebuild build \
    -workspace ChatKit-OC.xcworkspace \
    -scheme ChatKit-OC \
    -sdk iphonesimulator \
    -destination "id=$DEVICE_ID,arch=x86_64" \
    ONLY_ACTIVE_ARCH=NO \
    -derivedDataPath "$DERIVED" \
    CODE_SIGNING_ALLOWED=NO \
    COMPILER_INDEX_STORE_ENABLE=NO > "$ROOT/build/screenshots-build.log" 2>&1 || {
        grep -nE "(error|fatal error):|^ld: " "$ROOT/build/screenshots-build.log" | sort -u | head -n 80
        exit 1
    }
cd "$ROOT"

APP=$(find "$DERIVED/Build/Products" -maxdepth 2 -name '*.app' -path '*iphonesimulator*' | head -n 1)
BUNDLE_ID=$(/usr/libexec/PlistBuddy -c 'Print :CFBundleIdentifier' "$APP/Info.plist")
echo "App: $APP ($BUNDLE_ID)"

xcrun simctl boot "$DEVICE_ID" 2>/dev/null || true
xcrun simctl bootstatus "$DEVICE_ID" -b
xcrun simctl status_bar "$DEVICE_ID" override --time 9:41 --batteryState charged --batteryLevel 100 \
    --cellularBars 4 --wifiBars 3 || true
xcrun simctl install "$DEVICE_ID" "$APP"

shoot() {
    local name="$1"; shift
    xcrun simctl launch --terminate-running-process "$DEVICE_ID" "$BUNDLE_ID" "$@"
    sleep 8
    if ! xcrun simctl spawn "$DEVICE_ID" launchctl list | grep -q "$BUNDLE_ID"; then
        echo "warning: $BUNDLE_ID is not running after launch ($name); it may have crashed" >&2
    fi
    xcrun simctl io "$DEVICE_ID" screenshot "$OUT/$name.png"
    sips -s format jpeg -s formatOptions 60 --resampleWidth 390 "$OUT/$name.png" --out "$OUT/$name.jpg" >/dev/null
    echo "===BEGIN SCREENSHOT $name.jpg==="
    base64 -i "$OUT/$name.jpg" | fold -w 120
    echo "===END SCREENSHOT $name.jpg==="
}

shoot login
shoot conversations -LCCKDemoScreen conversations
shoot chat -LCCKDemoScreen chat

xcrun simctl spawn "$DEVICE_ID" log show --last 2m --style compact \
    --predicate "process == \"$(basename "$APP" .app)\"" > "$OUT/app.log" 2>/dev/null || true
ls -la "$OUT"
