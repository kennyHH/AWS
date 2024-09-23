#!/bin/bash

# Configuration
LOG_FILE="/var/log/tmp_cleanup.log"
TMP_DIR="/tmp"
EXCLUDE_DIRS=("." ".." ".X11-unix" ".XIM-unix" ".font-unix" ".ICE-unix")
MIN_AGE=1 # minutes

# Function to log actions
log_action() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" >> "$LOG_FILE"
}

# Function to check if a directory should be excluded
is_excluded() {
    local dir="$1"
    for exclude in "${EXCLUDE_DIRS[@]}"; do
        if [[ "$dir" == "$exclude" ]]; then
            return 0
        fi
    done
    return 1
}

# Clear /tmp folder
clear_tmp() {
    log_action "Starting /tmp cleanup"
    
    local removed_count=0
    local error_count=0
    
    # Use find to locate files and directories older than MIN_AGE minutes
    find "$TMP_DIR" -mindepth 1 -mmin +$MIN_AGE -print0 | while IFS= read -r -d '' item; do
        if is_excluded "$(basename "$item")"; then
            continue
        fi
        
        if rm -rf "$item" 2>/dev/null; then
            log_action "Removed: $item"
            ((removed_count++))
        else
            log_action "Error removing: $item"
            ((error_count++))
        fi
    done
    
    log_action "Finished /tmp cleanup. Removed $removed_count items. Errors: $error_count"
}

# Main execution
clear_tmp
