#!/bin/bash

# Function to generate a random password
generate_password() {
    < /dev/urandom tr -dc 'A-Za-z0-9' | head -c10
}

# Function to ensure file has the correct extension
ensure_extension() {
    local filename="$1"
    local extension="$2"
    if [[ $filename != *.$extension ]]; then
        filename="${filename}.${extension}"
    fi
    echo "$filename"
}

# Prompt for input filename
read -p "Enter the input filename (without extension): " input_file

# Ensure correct file extension for input
input_file=$(ensure_extension "$input_file" "txt")

# Check if input file exists
if [ ! -f "$input_file" ]; then
    echo "Error: Input file '$input_file' not found!"
    exit 1
fi

# Generate output filename
output_file="${input_file%.txt}.csv"

# Create CSV file with header
echo "USERNAME,PASSWORD,FULLNAME" > "$output_file"

# Process each line in the input file
while IFS= read -r line; do
    # Extract first name and surname
    first_name=$(echo "$line" | awk '{print $1}')
    surname=$(echo "$line" | awk '{print $2}')
    
    # Create username (HNC + first letter of first name + surname)
    username="HNC${first_name:0:1}${surname}"
    username=$(echo "$username" | tr '[:lower:]' '[:upper:]')
    
    # Generate random password
    password=$(generate_password)
    
    # Append to CSV file
    echo "${username},${password},${line}" >> "$output_file"
done < "$input_file"

echo "CSV file '$output_file' has been created successfully."
