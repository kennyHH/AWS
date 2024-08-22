#!/bin/bash

# List of folders to clean
folders=("apache" "home" "mysql_data" "setup_flag")

# Function to remove files in a folder
remove_files() {
    local folder=$1
    echo "Cleaning $folder..."
    
    # Find and print all files/folders to be removed, then remove them
    find "$folder" -mindepth 1 -not -name '.gitkeep' -print0 | while IFS= read -r -d '' file; do
        echo "Removing: $file"
        sudo rm -rf "$file"
    done
}

# Main script
for folder in "${folders[@]}"; do
    if [ -d "$folder" ]; then
        remove_files "$folder"
    else
        echo "Warning: $folder does not exist or is not a directory."
    fi
done

echo "Cleanup complete."
