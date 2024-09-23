#!/bin/bash

# Configuration
MAX_FILE_SIZE=20M  # Maximum allowed file size
LOG_FILE="/var/log/large_file_moves.log"
EXTENSIONS=(
    "zip" "rar" "7z" "tar" "gz" "bz2" "xz"  # Archive formats
    "mp4" "mkv" "avi" "mov" "flv" "wmv" "webm"  # Video formats
    "iso" "img"  # Disk image formats
    "exe" "bin"  # Executable formats
)

# Function to log actions
log_action() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" >> "$LOG_FILE"
}

# Scan user directories and move large files
scan_and_move() {
    for user_dir in /home/webdev/* /home/compsc/*; do
        username=$(basename "$user_dir")
        
        for ext in "${EXTENSIONS[@]}"; do
            find "$user_dir" -type f -name "*.$ext" -size +$MAX_FILE_SIZE -print0 | while IFS= read -r -d '' file; do
                filename=$(basename "$file")
                target_dir="/tmp/$username"
                mkdir -p "$target_dir"
                mv "$file" "$target_dir/"
                log_action "Moved file: $file to $target_dir/$filename"
            done
        done
    done
}

# Main execution
log_action "Starting large file scan"
scan_and_move
log_action "Finished large file scan"
