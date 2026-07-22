#!/bin/bash

# Directory where the Obsidian notes are located
WATCH_DIR="/vault"

BUILD_SCRIPT="/usr/src/app/scripts/build-quartz.sh"

# Delay in seconds before triggering a build after detecting file changes
BUILD_UPDATE_DELAY=${BUILD_UPDATE_DELAY:-300}

# Debounce state. Every detected change writes a fresh timestamp to this file.
# A scheduled build only runs if its timestamp is still the most recent one when
# its delay expires; otherwise a newer change superseded it and it exits. This
# resets the delay on each change without relying on killing background PIDs
# (which the previous implementation did incorrectly across a subshell boundary).
STAMP_FILE="$(mktemp)"

# Serialize builds so a change detected while a build is running queues behind it
# via flock instead of starting a second, overlapping build.
LOCK_FILE="/tmp/quartz-build.lock"

schedule_build() {
    local my_stamp
    my_stamp=$(date +%s%N)
    echo "$my_stamp" > "$STAMP_FILE"

    (
        sleep "$BUILD_UPDATE_DELAY"

        # A newer change arrived during the delay window; let that one build.
        if [[ "$(cat "$STAMP_FILE")" != "$my_stamp" ]]; then
            exit 0
        fi

        echo "Rebuilding site..."
        exec 9>"$LOCK_FILE"
        flock 9
        "$BUILD_SCRIPT"
        echo "Build complete!"
    ) &
}

# Watch the directory recursively (-r) so edits inside vault subfolders are
# detected, not just files sitting at the top level of the vault. Exclude vim
# swap files and anything under a .git directory (the latter is churned by
# VAULT_DO_GIT_PULL_ON_UPDATE and would otherwise generate noise).
inotifywait -m -r -e modify,move,create,delete --exclude '(/\.git/|\.swp$)' --format '%w%f' "$WATCH_DIR" | \
while read -r file; do
    if [[ "$file" =~ \.md$ && "$file" != *"Untitled.md"* ]]; then
        schedule_build
    fi
done
