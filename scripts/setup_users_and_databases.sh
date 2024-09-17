#!/bin/bash

chmod 755 /var/run/sshd

# Create group folders
mkdir -p /home/webdev /home/compsc
chmod 755 /home/webdev /home/compsc
chown root:root /home /home/webdev /home/compsc

# Function to create users and set up their environment
create_users() {
    local csv_file=$1
    local group=$2

    while IFS=',' read -r username password FULLNAME
    do
        # Skip the header line
        if [ "$username" != "USERNAME" ]; then
            # Determine home directory based on group
            case $group in
                "webdev")
                    home_dir="/home/webdev/${username}"
                    ;;
                "compsc")
                    home_dir="/home/compsc/${username}"
                    ;;
            esac

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
                
                echo "Created MySQL user: ${username}"
            else
                echo "User ${username} already exists. Updating home directory and group."
                usermod -d "${home_dir}" -g "${group}" "${username}"
            fi

            # Ensure home directory exists and set permissions
            mkdir -p "${home_dir}"
            chown root:root "${home_dir}"
            chmod 755 "${home_dir}"

            # Create 'website' directory for webdev group, 'files' directory for compsc
            if [ "$group" = "webdev" ]; then
                mkdir -p "${home_dir}/website"
                chown "${username}:${group}" "${home_dir}/website"
                chmod 755 "${home_dir}/website"
                echo "Set up web directory for user: ${username}"
            else
                mkdir -p "${home_dir}/files"
                chown "${username}:${group}" "${home_dir}/files"
                chmod 700 "${home_dir}/files"
            fi
        fi
    done < "$csv_file"
}

# Create users from CSV files
create_users "/root/users_csv/hncwebsa.csv" "webdev"
create_users "/root/users_csv/hndwebsa.csv" "webdev"

create_users "/root/users_csv/hncwebmr.csv" "webdev"
create_users "/root/users_csv/hndwebmr.csv" "webdev"

create_users "/root/users_csv/hnccssa.csv" "compsc"
create_users "/root/users_csv/hndcssa.csv" "compsc"

create_users "/root/users_csv/hnccsmr.csv" "compsc"
create_users "/root/users_csv/hndcsmr.csv" "compsc"

# Set correct permissions for /home directory
chmod 755 /home
chown root:root /home

# Flush privileges to ensure all changes take effect
mysql -h mysql -u root -p"${MYSQL_ROOT_PASSWORD}" -e "FLUSH PRIVILEGES;"

# Create a flag file to indicate that setup is done
touch /setup_flag/setup_done

echo "Initial setup completed."

