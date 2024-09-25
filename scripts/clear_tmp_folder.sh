#!/bin/bash

# Configuration
LOG_FILE="/var/log/tmp_cleanup.log"
TMP_DIR="/tmp"

# Function to log actions
log_action() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" >> "$LOG_FILE"
}

# Clear HN* folders in /tmp
clear_hn_folders() {
    log_action "Starting cleanup of HN* folders in /tmp"
    
    local total_removed=0
    local error_count=0
    
    # Find and remove HN* folders
    while IFS= read -r -d '' folder; do
        local items_count=$(find "$folder" -mindepth 1 | wc -l)
        if rm -rf "$folder" 2>/dev/null; then
            log_action "Removed folder: $folder (containing $items_count items)"
            ((total_removed += items_count + 1))  # +1 for the folder itself
        else
            log_action "Error removing folder: $folder"
            ((error_count++))
        fi
    done < <(find "$TMP_DIR" -maxdepth 1 -type d -name "HN*" -print0)
    
    log_action "Finished cleanup. Removed $total_removed items (including folders). Errors: $error_count"
}

# Main execution
clear_hn_folders
