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

    # Display group options and get selection
    echo "Select a group for the usernames (or type 'quit' to exit):"
    PS3=$'Please enter your choice:\n'
    select choice in "${sorted_groups[@]}" "quit"; do
        if [[ "$choice" == "quit" ]]; then
            echo "Exiting the script. Goodbye!"
            exit 0
        elif [[ -n "$choice" ]]; then
            group="$choice"
            echo "You selected $group"
            break
        else
            echo "Invalid selection. Please try again."
        fi
    done

    # Check if user wants to quit
    if [[ "$REPLY" == "quit" ]]; then
        echo "Exiting the script. Goodbye!"
        exit 0
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
