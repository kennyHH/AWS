#!/bin/bash

# Configuration
MAX_FILE_SIZE=25M  # Adjust as needed
LOG_FILE="/var/log/large_file_moves.log"
SEARCH_DIRS=("/home/webdev" "/home/compsc")

# Function to log actions
log_action() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" >> "$LOG_FILE"
}

# Function to extract username from file path
get_username() {
    local file_path="$1"
    local home_dir="$2"
    echo "$file_path" | awk -F"$home_dir/" '{print $2}' | cut -d'/' -f1
}

# Scan directories and move large files
scan_and_move() {

    for dir in "${SEARCH_DIRS[@]}"; do
        log_action "Scanning directory: $dir"
        
        find "$dir" -type f -size +$MAX_FILE_SIZE -print0 | while IFS= read -r -d '' file; do
            local username=$(get_username "$file" "$dir")
            local filename=$(basename "$file")
            local target_dir="/tmp/$username"
            local filesize=$(du -h "$file" | cut -f1)
            
            log_action "Found file: $file (Size: $filesize, Username: $username)"
            
            mkdir -p "$target_dir"
            if mv "$file" "$target_dir/"; then
                log_action "Moved file: $file to $target_dir/$filename"
            else
                log_action "Failed to move file: $file"
            fi
        done
    done
}

# Main execution
log_action "Starting large file scan"
scan_and_move
log_action "Finished large file scan"


