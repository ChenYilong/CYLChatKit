#!/bin/bash
# Usage: scripts/ci-build-example.sh <demo folder>     e.g. scripts/ci-build-example.sh ChatKit-OC
#
# CI helper (docs/ci.md), adapted from CYLTabBarController's scripts/ci-build-example.sh: builds one demo for the
# iOS Simulator, without code signing.
# - Runs `pod install` when the folder has a Podfile. First it pins CYLTabBarController in that Podfile to the newest
#   commit on any branch (scripts/update-cyltabbarcontroller-commit.sh; CYLTABBARCONTROLLER_COMMIT overrides the lookup).
# - Uses the folder's .xcworkspace when there is one, else its .xcodeproj.
# - Picks the app scheme from `xcodebuild -list -json`: the first scheme named after an application target of the
#   demo's own .xcodeproj (not Pods), so the app's own sources are compiled, not only the library.
# Prints a summary line for the job summary and exits with xcodebuild's status.
set -euo pipefail

DEMO_DIR="${1:?usage: $0 <demo folder>}"
cd "$(dirname "$0")/.."
ROOT="$PWD"
mkdir -p "$ROOT/build"
cd "$DEMO_DIR"

if [[ -f Podfile ]]; then
    # CYLTabBarController is always the newest commit of its repository (AGENTS.md): pin it before installing.
    if grep -qE "^[[:space:]]*pod 'CYLTabBarController'" Podfile; then
        "$ROOT/scripts/update-cyltabbarcontroller-commit.sh" --podfile "$PWD/Podfile" > /dev/null
    fi
    pod install --repo-update
fi

# Globs that match nothing expand to nothing.
shopt -s nullglob
WORKSPACES=(./*.xcworkspace)
PROJECTS=(./*.xcodeproj)
shopt -u nullglob
if [[ ${#WORKSPACES[@]} -gt 0 ]]; then
    CONTAINER_FLAG="-workspace"
    CONTAINER="${WORKSPACES[0]}"
elif [[ ${#PROJECTS[@]} -gt 0 ]]; then
    CONTAINER_FLAG="-project"
    CONTAINER="${PROJECTS[0]}"
else
    echo "error: no .xcworkspace or .xcodeproj in $DEMO_DIR" >&2
    exit 1
fi

LIST_JSON=$(xcodebuild -list -json "$CONTAINER_FLAG" "$CONTAINER")
SCHEME=$(printf '%s' "$LIST_JSON" | /usr/bin/python3 -c '
import json, re, sys
data = json.load(sys.stdin)
info = data.get("workspace") or data.get("project") or {}
schemes = info.get("schemes", [])
app_targets = set()
for project in sys.argv[1:]:
    if project.endswith("Pods.xcodeproj"):
        continue
    try:
        pbxproj = open(project + "/project.pbxproj", encoding="utf-8").read()
    except OSError:
        continue
    for target in re.findall(r"isa = PBXNativeTarget;(.*?)\n\t\t\};", pbxproj, re.S):
        name = re.search(r"\bname = \"?([^\";]+)\"?;", target)
        if name and "com.apple.product-type.application\"" in target:
            app_targets.add(name.group(1))
apps = [s for s in schemes if s in app_targets]
skip = ("Pods", "Test", "Tests", "UITests", "CYLChatKit", "CYLTabBarController")
others = [s for s in schemes if not any(word in s for word in skip)]
print((apps or others or schemes or [""])[0])
' "${PROJECTS[@]}")
if [[ -z "$SCHEME" ]]; then
    echo "error: no scheme found in $DEMO_DIR/$CONTAINER" >&2
    printf '%s\n' "$LIST_JSON" >&2
    exit 1
fi

echo "Building $DEMO_DIR/$CONTAINER, scheme $SCHEME"
set +e
xcodebuild build \
    "$CONTAINER_FLAG" "$CONTAINER" \
    -scheme "$SCHEME" \
    -destination 'generic/platform=iOS Simulator' \
    -derivedDataPath "$ROOT/build/DerivedData/$DEMO_DIR" \
    CODE_SIGNING_ALLOWED=NO \
    ONLY_ACTIVE_ARCH=NO \
    COMPILER_INDEX_STORE_ENABLE=NO 2>&1 | tee "$ROOT/build/$DEMO_DIR.log"
STATUS=${PIPESTATUS[0]}
set -e

if [[ "$STATUS" -ne 0 ]]; then
    echo "Build failed. Errors:"
    grep -nE "(error|fatal error):|^ld: |Undefined symbols" "$ROOT/build/$DEMO_DIR.log" | sort -u | head -n 80 || true
fi
WARNINGS=$(grep -c ': warning: ' "$ROOT/build/$DEMO_DIR.log" || true)
echo "| $DEMO_DIR | \`$SCHEME\` | $([[ "$STATUS" -eq 0 ]] && echo ✅ || echo ❌) | $WARNINGS |" >> "$ROOT/build/summary.md"
exit "$STATUS"
