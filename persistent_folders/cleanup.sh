#!/bin/bash

# Function to remove files and directories
remove_files() {
    local directory=$1
    local exclude_file=$2

    find "$directory" -mindepth 1 ! -name "$exclude_file" | while read item; do
        if [ -f "$item" ] || [ -h "$item" ]; then
            rm -f "$item" && echo "Removed file: $item"
        elif [ -d "$item" ]; then
            rm -rf "$item" && echo "Removed directory: $item"
        else
            echo "Unknown file type, skipping: $item"
        fi
    done

    # Specific check for mysql.sock
    if [ "$directory" = "mysql_data" ] && [ -S "$directory/mysql.sock" ]; then
        rm -f "$directory/mysql.sock" && echo "Removed socket file: $directory/mysql.sock"
    fi
}

# Main script
echo "This script will remove all files and subdirectories in the following folders:"
echo "- mysql_data"
echo "- setup_flag"
echo "- othersome"
echo "- apache"
echo "Note: The file '000-default.conf' in the 'apache' folder will be preserved."

read -p "Are you sure you want to proceed? (yes/no): " confirmation

confirmation=$(echo "$confirmation" | tr '[:upper:]' '[:lower:]')
if [ "$confirmation" != "yes" ]; then
    echo "Operation cancelled."
    exit 0
fi

# Clean up each directory
remove_files "mysql_data"
remove_files "setup_flag"
remove_files "othershome"
remove_files "apache" "000-default.conf"

echo "Cleanup completed."
