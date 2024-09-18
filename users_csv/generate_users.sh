#!/bin/bash

# Array of group options with their corresponding input files
declare -A group_options=(
    ["HNCWEBSA"]="hncwebsa.txt"
    ["HNDWEBSA"]="hndwebsa.txt"
    ["HNCWEBMR"]="hncwebmr.txt"
    ["HNDWEBMR"]="hndwebmr.txt"
    ["HNCCSSA"]="hncwebsa.txt"
    ["HNDCSSA"]="hndwebsa.txt"
    ["HNCCSMR"]="hncwebmr.txt"
    ["HNDCSMR"]="hndwebmr.txt"
)

# Function to generate a random password
generate_password() {
    < /dev/urandom tr -dc 'A-Za-z0-9' | head -c10
}

# Main loop
while true; do
    # Sort the group names
    sorted_groups=($(echo "${!group_options[@]}" | tr ' ' '\n' | sort))

    # Display group options
    echo "Select a group for the usernames (or enter 'q' to quit):"
    for i in "${!sorted_groups[@]}"; do
        echo "$((i+1)). ${sorted_groups[i]}"
    done
    echo "q. Quit"

    # Get user selection
    read -p "Enter your choice: " choice

    if [[ "$choice" == "q" ]]; then
        echo "Exiting the script. Goodbye!"
        exit 0
    elif [[ "$choice" =~ ^[0-9]+$ ]] && [ "$choice" -ge 1 ] && [ "$choice" -le "${#sorted_groups[@]}" ]; then
        group="${sorted_groups[$((choice-1))]}"
        echo "You selected $group"
    else
        echo "Invalid selection. Please try again."
        continue
    fi

    # Get the corresponding input file
    input_file="${group_options[$group]}"

    # Check if input file exists
    if [ ! -f "$input_file" ]; then
        echo "Error: Input file '$input_file' not found!"
        continue
    fi

    # Create output directory if it doesn't exist
    mkdir -p csv

    # Generate output filename (in lowercase)
    output_file="csv/$(echo ${group,,}).csv"

    # Create CSV file with header
    echo "USERNAME,PASSWORD,FULLNAME" > "$output_file"

    # Process each line in the input file
    while IFS= read -r line; do
        # Extract first name and surname
        first_name=$(echo "$line" | awk '{print $1}')
        surname=$(echo "$line" | awk '{print $2}')
        
        # Create username (selected group + first letter of first name + surname)
        username="${group}${first_name:0:1}${surname}"
        username=$(echo "$username" | tr '[:lower:]' '[:upper:]')
        
        # Generate random password
        password=$(generate_password)
        
        # Append to CSV file
        echo "${username},${password},${line}" >> "$output_file"
    done < "$input_file"

    echo "CSV file '$output_file' has been created successfully."
    echo
done
