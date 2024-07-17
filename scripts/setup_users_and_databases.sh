#!/bin/bash

chmod 755 /var/run/sshd

# Function to create users and set up their environment
create_users() {
    local csv_file=$1
    local group=$2
    local needs_web_access=$3

    while IFS=',' read -r username password
    do
        # Skip the header line
        if [ "$username" != "username" ]; then
            # Check if the database already exists
            if ! mysql -h mysql -u root -p"${MYSQL_ROOT_PASSWORD}" -e "USE ${username}_db;" 2>/dev/null; then
                # Create database if it doesn't exist
                mysql -h mysql -u root -p"${MYSQL_ROOT_PASSWORD}" -e "CREATE DATABASE ${username}_db;"
                echo "Created database: ${username}_db"
            else
                echo "Database ${username}_db already exists. Skipping."
            fi

            # Check if the user already exists
            if ! id -u "${username}" >/dev/null 2>&1; then
                # Create user's system account with home directory
                useradd -m -d "/home/${username}" -s /bin/bash -g "${group}" "${username}"
                # Set password directly from CSV
                echo "${username}:${password}" | chpasswd
                echo "Created system user: ${username}"

                # Create MySQL user and grant privileges
                mysql -h mysql -u root -p"${MYSQL_ROOT_PASSWORD}" -e "CREATE USER '${username}'@'%' IDENTIFIED BY '${password}';"
                mysql -h mysql -u root -p"${MYSQL_ROOT_PASSWORD}" -e "GRANT ALL PRIVILEGES ON ${username}_db.* TO '${username}'@'%';"
                mysql -h mysql -u root -p"${MYSQL_ROOT_PASSWORD}" -e "ALTER USER '${username}'@'%' IDENTIFIED BY '${password}';"
                echo "Created MySQL user: ${username}"
            fi

            # Set permissions based on group
            if [ "$group" = "hncwebsa" ]; then
                # More permissive for hncwebsa group
                chmod 755 "/home/${username}"
                if [ "$needs_web_access" = true ]; then
                    # Set up web directory
                    mkdir -p "/home/${username}/website"
                    chown "${username}:${group}" "/home/${username}/website"
                    chmod 755 "/home/${username}/website"
                    echo "Set up web directory for user: ${username}"
                    chown "root:root" "/home/${username}"
                fi
            else
                # More restrictive for other groups
                chmod 700 "/home/${username}"
                chown "${username}:${group}" "/home/${username}"
            fi
            
        fi
    done < "$csv_file"
}

# Create users from hncwebsa.csv
create_users "/root/hncwebsa.csv" "hncwebsa" true

# Create users from hnccssa.csv
create_users "/root/hnccssa.csv" "hnccssa" false

# Create users from others.csv
create_users "/root/hncothers.csv" "hncothers" false

# Set correct permissions for /home directory
chmod 755 /home

# Flush privileges to ensure all changes take effect
mysql -h mysql -u root -p"${MYSQL_ROOT_PASSWORD}" -e "FLUSH PRIVILEGES;"

# Create a flag file to indicate that setup is done
touch /setup_flag/setup_done

echo "Initial setup completed."
