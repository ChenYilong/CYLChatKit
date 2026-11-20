#!/bin/bash
# Usage: scripts/update-cyltabbarcontroller-commit.sh [--print] [--podfile <path>]
#
# Finds the newest commit of CYLTabBarController, on ANY branch (not only master or main), and pins the demo Podfile to
# it. "Newest" is the commit (committer) timestamp, compared across the tip of every branch. See AGENTS.md,
# "CYLTabBarController dependency". Run it before every build; CI runs it once per workflow run.
#
#   --print            only print the result, leave the Podfile alone
#   --podfile <path>   Podfile to rewrite (default: ChatKit-OC/Podfile)
#
# CYLTABBARCONTROLLER_COMMIT=<sha> skips the lookup and pins that commit. CI uses it so every job of one run builds
# the same commit.
#
# Output (stdout): sha=<40 hex>, branch=<branch name>, date=<UTC commit time>. Messages go to stderr.
set -euo pipefail

REPO_URL="https://github.com/ChenYilong/CYLTabBarController.git"
cd "$(dirname "$0")/.."
PODFILE="ChatKit-OC/Podfile"
PRINT_ONLY=0
while [[ $# -gt 0 ]]; do
    case "$1" in
        --print) PRINT_ONLY=1; shift ;;
        --podfile) PODFILE="${2:?--podfile needs a path}"; shift 2 ;;
        *) echo "usage: $0 [--print] [--podfile <path>]" >&2; exit 2 ;;
    esac
done

WORK=$(mktemp -d)
trap 'rm -rf "$WORK"' EXIT
# Commits only (no trees or blobs), tip of every branch: fast, and enough to compare timestamps.
git clone --quiet --no-checkout --filter=tree:0 --depth=1 --no-single-branch "$REPO_URL" "$WORK/repo"

if [[ -n "${CYLTABBARCONTROLLER_COMMIT:-}" ]]; then
    SHA="$CYLTABBARCONTROLLER_COMMIT"
    BRANCH="(given)"
    DATE="(given)"
else
    # --sort: the last key is the primary one, so this sorts by commit time, newest first, and by branch name on ties.
    # origin/HEAD is only an alias of the default branch.
    LATEST=$(TZ=UTC git -C "$WORK/repo" for-each-ref --sort=refname --sort=-committerdate \
        --format='%(objectname) %(committerdate:format-local:%Y-%m-%dT%H:%M:%SZ) %(refname:strip=3)' \
        refs/remotes/origin | awk '$3 != "HEAD"' | head -n 1)
    SHA="${LATEST%% *}"
    REST="${LATEST#* }"
    DATE="${REST%% *}"
    BRANCH="${REST#* }"
fi

if [[ ! "$SHA" =~ ^[0-9a-f]{40}$ ]]; then
    echo "error: could not resolve a commit of $REPO_URL (got '$SHA')" >&2
    exit 1
fi
# The commit must carry the podspec in its root, otherwise CocoaPods cannot use it.
git -C "$WORK/repo" fetch --quiet --depth=1 origin "$SHA" 2>/dev/null || true
if ! git -C "$WORK/repo" cat-file -e "$SHA:CYLTabBarController.podspec" 2>/dev/null; then
    echo "error: commit $SHA has no CYLTabBarController.podspec in its root" >&2
    exit 1
fi

echo "CYLTabBarController: newest commit $SHA on branch '$BRANCH', committed $DATE" >&2
printf 'sha=%s\nbranch=%s\ndate=%s\n' "$SHA" "$BRANCH" "$DATE"

if [[ "$PRINT_ONLY" -eq 1 ]]; then
    exit 0
fi

if ! grep -qE "^[[:space:]]*pod 'CYLTabBarController'" "$PODFILE"; then
    echo "error: $PODFILE has no \"pod 'CYLTabBarController'\" line" >&2
    exit 1
fi
sed -E "s|^([[:space:]]*)pod 'CYLTabBarController'.*\$|\\1pod 'CYLTabBarController', :git => '${REPO_URL%.git}.git', :commit => '${SHA}'|" \
    "$PODFILE" > "$WORK/Podfile"
if cmp -s "$WORK/Podfile" "$PODFILE"; then
    echo "$PODFILE already pins $SHA" >&2
else
    cat "$WORK/Podfile" > "$PODFILE"
    echo "$PODFILE now pins $SHA" >&2
fi
