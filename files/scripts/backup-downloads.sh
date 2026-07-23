#!/bin/bash
set -euo pipefail

TIME_PERIOD="1month"
ARCHIVE_DIR="$HOME/Documents/Download Archive"
TAR_FILE="$ARCHIVE_DIR/$(date +'%Y-%m-%d_%H%M%S').tar"

mkdir -p "$ARCHIVE_DIR"
cd "$HOME/Downloads"

# Build the exclusion list once
mapfile -t recent < <(
    fd . "--changed-after=$TIME_PERIOD" --prune | cut -f1 -d/ | sort -u
)

ignore_file=$(mktemp)

trap 'rm -f "$ignore_file"' EXIT
printf '/%s\n' "${recent[@]}" > "$ignore_file"

# Capture the list of stale entries once, reuse for tar + trash
mapfile -t stale < <(
    fd . "--changed-before=$TIME_PERIOD" --max-depth 1 --ignore-file "$ignore_file"
)

if [ "${#stale[@]}" -eq 0 ]; then
    echo "Nothing to archive."
    exit 0
fi

tar -cf "$TAR_FILE" -- "${stale[@]}"
xz "$TAR_FILE"                      # only reached if tar succeeded (set -e)
trash -- "${stale[@]}"              # only reached if xz succeeded
