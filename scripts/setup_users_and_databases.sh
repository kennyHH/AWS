#!/bin/bash

chmod 755 /var/run/sshd

# Create webdev and others folders
mkdir -p /home/webdev /home/others
chmod 755 /home/webdev /home/others
chown root:root /home /home/webdev /home/others

# Function to create users and set up their environment
create_users() {
    local csv_file=$1
    local group=$2
    local needs_web_access=$3

    while IFS=',' read -r username password FULLNAME
    do
        # Skip the header line
        if [ "$username" != "USERNAME" ]; then
            # Determine home directory based on group
            if [ "$group" = "webdev" ]; then
                home_dir="/home/webdev/${username}"
            else
                home_dir="/home/others/${username}"
            fi

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
                useradd -m -d "${home_dir}" -s /bin/bash -g "${group}" "${username}"
                # Set password directly from CSV
                echo "${username}:${password}" | chpasswd
                echo "Created system user: ${username}"

                # Create MySQL user and grant privileges
                mysql -h mysql -u root -p"${MYSQL_ROOT_PASSWORD}" -e "CREATE USER '${username}'@'%' IDENTIFIED BY '${password}';"
                mysql -h mysql -u root -p"${MYSQL_ROOT_PASSWORD}" -e "GRANT ALL PRIVILEGES ON \`${username}_%\`.* TO '${username}'@'%';"
                mysql -h mysql -u root -p"${MYSQL_ROOT_PASSWORD}" -e "FLUSH PRIVILEGES;"
                
                echo "Created MySQL user: ${username}"
            else
                echo "User ${username} already exists. Updating home directory and group."
                usermod -d "${home_dir}" -g "${group}" "${username}"
            fi

            # Ensure home directory exists and set permissions
            mkdir -p "${home_dir}"
            chown root:root "${home_dir}"
            chmod 755 "${home_dir}"

            if [ "$group" = "webdev" ]; then
                # For webdev group, create 'website' directory
                if [ "$needs_web_access" = true ]; then
                    mkdir -p "${home_dir}/website"
                    chown "${username}:${group}" "${home_dir}/website"
                    chmod 755 "${home_dir}/website"
                    echo "Set up web directory for user: ${username}"
                fi
            else
                # For other groups, create 'files' directory
                mkdir -p "${home_dir}/files"
                chown "${username}:${group}" "${home_dir}/files"
                chmod 700 "${home_dir}/files"
            fi
        fi
    done < "$csv_file"
}

# Create users from webdev.csv
create_users "/root/users_csv/hncwebsa.csv" "webdev" true
create_users "/root/users_csv/hncwebmr.csv" "webdev" true

# Create users from hnccssa.csv
create_users "/root/users_csv/hnccssa.csv" "hnccssa" false

# Create users from others.csv
create_users "/root/users_csv/hncothers.csv" "hncothers" false

# Set correct permissions for /home directory
chmod 755 /home
chown root:root /home

# Flush privileges to ensure all changes take effect
mysql -h mysql -u root -p"${MYSQL_ROOT_PASSWORD}" -e "FLUSH PRIVILEGES;"

# Create a flag file to indicate that setup is done
touch /setup_flag/setup_done

echo "Initial setup completed."
