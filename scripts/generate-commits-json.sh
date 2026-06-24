#!/usr/bin/env bash
# Generate data/commits.json mapping content file paths to their last commit hash.
# Used by the date partial to link timestamps to commits.

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
DATA_DIR="$REPO_ROOT/data"
OUTPUT="$DATA_DIR/commits.json"

ORIGIN_URL="$(git -C "$REPO_ROOT" remote get-url origin 2>/dev/null || echo "")"

# Parse host, owner, repo from SSH URL like git@host:owner/repo.git
if [[ "$ORIGIN_URL" =~ ^git@([^:]+):(.+)$ ]]; then
  HOST="${BASH_REMATCH[1]}"
  REPO_PATH="${BASH_REMATCH[2]}"
else
  # Fallback for HTTPS or unknown format
  echo '{"error":"could not parse origin URL"}' > "$OUTPUT"
  exit 0
fi

REPO_NAME="$(basename -s .git "$REPO_PATH")"
OWNER="${REPO_PATH%/*}"

CONTENT_DIR="$REPO_ROOT/content"

# Start JSON
echo '{' > "$OUTPUT"

FIRST=true
if [ -d "$CONTENT_DIR" ]; then
  while IFS= read -r -d '' file; do
    REL_PATH="${file#$CONTENT_DIR/}"
    COMMIT="$(git -C "$REPO_ROOT" log -1 --format=%H -- "$file" 2>/dev/null || echo "")"

    if [ -n "$COMMIT" ]; then
      URL="https://${HOST}/${OWNER}/${REPO_NAME}/commit/${COMMIT}"
    else
      URL=""
    fi

    if [ "$FIRST" = true ]; then
      FIRST=false
    else
      echo ',' >> "$OUTPUT"
    fi
    printf '  "%s": {"hash": "%s", "url": "%s"}' "$REL_PATH" "$COMMIT" "$URL" >> "$OUTPUT"
  done < <(find "$CONTENT_DIR" -name '*.md' -print0 | sort -z)
fi

echo '' >> "$OUTPUT"
echo '}' >> "$OUTPUT"
