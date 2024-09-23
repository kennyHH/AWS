#!/bin/bash

# Function to check if a user exists
user_exists() {
    local username=$1
    local exists=$(mysql -u root -p"${MYSQL_ROOT_PASSWORD}" -sN -e "SELECT EXISTS(SELECT 1 FROM mysql.user WHERE user = '$username')")
    [ "$exists" == "1" ]
}

# Function to create MySQL user and database for regular users
create_mysql_user_and_db() {
    local username=$1
    local password=$2
    if ! user_exists "$username"; then
        mysql -u root -p"${MYSQL_ROOT_PASSWORD}" <<EOF
CREATE USER '${username}'@'%' IDENTIFIED BY '${password}';
GRANT ALL PRIVILEGES ON \`${username}_%\`.* TO '${username}'@'%';
FLUSH PRIVILEGES;
EOF
        echo "Created MySQL user and granted privileges for: ${username}"
    else
        echo "User ${username} already exists. Skipping."
    fi
}

# Function to create MySQL admin user with full privileges
create_mysql_admin_user() {
    local username=$1
    local password=$2
    if ! user_exists "$username"; then
        mysql -u root -p"${MYSQL_ROOT_PASSWORD}" <<EOF
CREATE USER '${username}'@'%' IDENTIFIED BY '${password}';
GRANT ALL PRIVILEGES ON *.* TO '${username}'@'%' WITH GRANT OPTION;
FLUSH PRIVILEGES;
EOF
        echo "Created MySQL admin user with full privileges: ${username}"
    else
        echo "Admin user ${username} already exists. Skipping."
    fi
}

# Function to process regular user CSV file
process_regular_csv() {
    local csv_file=$1
    
    while IFS=',' read -r username password _
    do
        # Skip the header line and empty usernames
        if [ "$username" != "USERNAME" ] && [ -n "$username" ]; then
            create_mysql_user_and_db "$username" "$password"
        fi
    done < "$csv_file"
}

# Function to process admin user CSV file
process_admin_csv() {
    local csv_file=$1
    
    while IFS=',' read -r username password _
    do
        # Skip the header line and empty usernames
        if [ "$username" != "USERNAME" ] && [ -n "$username" ]; then
            create_mysql_admin_user "$username" "$password"
        fi
    done < "$csv_file"
}

# Main execution
echo "Setting up MySQL users, databases, and admin users..."

# Process regular user CSV files
for csv_file in \
    "/docker-entrypoint-initdb.d/csv/hncwebsa.csv" \
    "/docker-entrypoint-initdb.d/csv/hndwebsa.csv" \
    "/docker-entrypoint-initdb.d/csv/hncwebmr.csv" \
    "/docker-entrypoint-initdb.d/csv/hndwebmr.csv" \
    "/docker-entrypoint-initdb.d/csv/hnccssa.csv" \
    "/docker-entrypoint-initdb.d/csv/hndcssa.csv" \
    "/docker-entrypoint-initdb.d/csv/hnccsmr.csv" \
    "/docker-entrypoint-initdb.d/csv/hndcsmr.csv"
do
    if [ -f "$csv_file" ]; then
        echo "Processing regular user file: $csv_file"
        process_regular_csv "$csv_file"
    else
        echo "Warning: $csv_file not found"
    fi
done

# Process admin user CSV file
admin_csv="/docker-entrypoint-initdb.d/csv/admin_users.csv"
if [ -f "$admin_csv" ]; then
    echo "Processing admin user file: $admin_csv"
    process_admin_csv "$admin_csv"
else
    echo "Warning: $admin_csv not found"
fi

echo "MySQL users, databases, and admin users setup completed."
