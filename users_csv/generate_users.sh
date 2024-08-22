#!/bin/bash

# Function to generate a random password
generate_password() {
    < /dev/urandom tr -dc 'A-Za-z0-9' | head -c10
}

# Prompt for input and output filenames
read -p "Enter the input text filename: " input_file
read -p "Enter the CSV filename: " output_file

# Check if input file exists
if [ ! -f "$input_file" ]; then
    echo "Error: Input file not found!"
    exit 1
fi

# Create CSV file with header
echo "USER,PASSWORD,FULLNAME" > "$output_file"

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
