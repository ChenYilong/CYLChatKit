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
# CYLTabBarController is always the newest commit of its repository (AGENTS.md): pin it before installing.
"$ROOT/scripts/update-cyltabbarcontroller-commit.sh" --podfile "$PWD/Podfile" > /dev/null
# Pods/ is partly committed, so always install.
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
# The demo's -LCCKDemoScreenshots flag keeps system overlays out of the screenshots: it skips the notification
# permission request and does not open the keyboard (whose first-run swipe-typing introduction covers the screen).
xcrun simctl install "$DEVICE_ID" "$APP"
PROCESS_NAME=$(/usr/libexec/PlistBuddy -c 'Print :CFBundleExecutable' "$APP/Info.plist")

# Prints the newest crash report newer than the given marker file, plus exception lines from the app's log, so a crash
# can be diagnosed from the job log alone (artifacts are not always reachable).
print_crash() {
    local marker="$1" report
    report=$(find "$HOME/Library/Logs/DiagnosticReports" -name "${PROCESS_NAME}*" -newer "$marker" 2>/dev/null \
        | head -n 1)
    echo "::group::Crash details"
    if [[ -n "$report" ]]; then
        echo "Crash report: $report"
        /usr/bin/python3 - "$report" <<'PY' || head -n 120 "$report"
import json, sys
text = open(sys.argv[1], encoding="utf-8", errors="replace").read()
header, _, body = text.partition("\n")
data = json.loads(body)
exc = data.get("exception", {})
print("exception:", exc.get("type"), exc.get("signal"), data.get("asi") or "")
info = data.get("lastExceptionBacktrace") and "lastExceptionBacktrace present" or ""
print(info)
images = data.get("usedImages", [])
for key in ("lastExceptionBacktrace",):
    frames = data.get(key) or []
    for f in frames[:25]:
        img = images[f.get("imageIndex", 0)].get("name", "?") if images else "?"
        print("  ", img, f.get("symbol", ""), "+", f.get("symbolLocation", ""))
threads = data.get("threads", [])
crashed = next((t for t in threads if t.get("triggered")), threads[0] if threads else {})
for f in crashed.get("frames", [])[:25]:
    img = images[f.get("imageIndex", 0)].get("name", "?") if images else "?"
    print("  ", img, f.get("symbol", ""), "+", f.get("symbolLocation", ""))
PY
    else
        echo "No crash report found for $PROCESS_NAME."
    fi
    xcrun simctl spawn "$DEVICE_ID" log show --last 1m --style compact \
        --predicate "process == \"$PROCESS_NAME\"" 2>/dev/null \
        | grep -iE "exception|terminating|assert|fault|error" | tail -n 40 || true
    echo "::endgroup::"
}

# Succeeds when the image is (almost) all black: the mean byte value of its uncompressed pixels is below 6.
is_black() {
    local bmp="${1%.jpg}.bmp"
    sips -s format bmp "$1" --out "$bmp" > /dev/null
    /usr/bin/python3 - "$bmp" <<'PY'
import sys
data = open(sys.argv[1], "rb").read()
pixels = data[int.from_bytes(data[10:14], "little"):]
sample = pixels[::max(1, len(pixels) // 20000)]
sys.exit(0 if sum(sample) / len(sample) < 6 else 1)
PY
}

shoot() {
    local name="$1"; shift
    local started
    started=$(mktemp)
    xcrun simctl launch --terminate-running-process "$DEVICE_ID" "$BUNDLE_ID" -LCCKDemoScreenshots YES "$@"
    sleep 8
    if ! xcrun simctl spawn "$DEVICE_ID" launchctl list | grep -q "$BUNDLE_ID"; then
        echo "::error::$BUNDLE_ID is not running after launch ($name); it crashed"
        print_crash "$started"
        CRASHED="$CRASHED $name"
    fi
    # The first launch after installing can take long (the app runs translated under Rosetta), and a screenshot taken
    # before the first frame is black. Retake it while the screen is black, and fail if it never gets content.
    local attempt=0
    while :; do
        xcrun simctl io "$DEVICE_ID" screenshot "$OUT/$name.png"
        sips -s format jpeg -s formatOptions 60 --resampleWidth 390 "$OUT/$name.png" --out "$OUT/$name.jpg" >/dev/null
        is_black "$OUT/$name.jpg" || break
        attempt=$((attempt + 1))
        if [[ "$attempt" -ge 8 ]]; then
            echo "::error::the $name screenshot is still black after $attempt retries"
            BLACK="$BLACK $name"
            break
        fi
        echo "$name: the screen is still black, waiting (retry $attempt)"
        sleep 4
    done
    echo "$name: screenshot taken after $attempt retries"
    echo "===BEGIN SCREENSHOT $name.jpg==="
    base64 -i "$OUT/$name.jpg" | fold -w 120
    echo "===END SCREENSHOT $name.jpg==="
}

CRASHED=""
BLACK=""
shoot login
shoot conversations -LCCKDemoScreen conversations
shoot chat -LCCKDemoScreen chat

xcrun simctl spawn "$DEVICE_ID" log show --last 2m --style compact \
    --predicate "process == \"$PROCESS_NAME\"" > "$OUT/app.log" 2>/dev/null || true
ls -la "$OUT"
if [[ -n "$CRASHED" ]]; then
    echo "error: the demo crashed on:$CRASHED" >&2
    exit 1
fi
if [[ -n "$BLACK" ]]; then
    echo "error: these screenshots stayed black:$BLACK" >&2
    exit 1
fi
