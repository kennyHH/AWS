#!/bin/bash

# Function to create users without setting up home directories
create_user() {
    local username=$1
    local password=$2
    local group=$3
    local fullname=$4

    # Determine home directory based on group
    case $group in
        "webdev")
            home_dir="/home/webdev/${username}"
            ;;
        "compsc")
            home_dir="/home/compsc/${username}"
            ;;
        "admin")
            home_dir="/home/admins/${username}"
            ;;
    esac

    # Check if the user already exists
    if ! id -u "${username}" >/dev/null 2>&1; then
        # Create user's system account without creating home directory
        useradd -M -d "${home_dir}" -s /bin/bash -g "${group}" "${username}"
        # Set password
        echo "${username}:${password}" | chpasswd
        echo "Created system user: ${username}"

        # For admin users, add to sudo group
        if [ "$group" = "admin" ]; then
            usermod -aG sudo "${username}"
            echo "Added ${username} to sudo group"
        fi
    else
        echo "User ${username} already exists. Updating password and group."
        usermod -d "${home_dir}" -g "${group}" "${username}"
        echo "${username}:${password}" | chpasswd

        # Ensure admin users are in sudo group
        if [ "$group" = "admin" ]; then
            usermod -aG sudo "${username}"
        fi
    fi

    # Ensure home directory exists with correct permissions
    mkdir -p "${home_dir}"
    chown "${username}:${group}" "${home_dir}"
    chmod 755 "${home_dir}"

    # Create appropriate subdirectories based on group
    if [ "$group" = "webdev" ]; then
        mkdir -p "${home_dir}/website"
        chown "${username}:${group}" "${home_dir}/website"
        chmod 755 "${home_dir}/website"
    elif [ "$group" = "compsc" ]; then
        mkdir -p "${home_dir}/files"
        chown "${username}:${group}" "${home_dir}/files"
        chmod 700 "${home_dir}/files"
    elif [ "$group" = "admin" ]; then
        mkdir -p "${home_dir}/.ssh"
        chown "${username}:${group}" "${home_dir}/.ssh"
        chmod 700 "${home_dir}/.ssh"
    fi
}

# Function to process CSV file
process_csv() {
    local csv_file=$1
    local group=$2
    
    while IFS=',' read -r username password fullname
    do
        # Skip the header line
        if [ "$username" != "USERNAME" ]; then
            create_user "$username" "$password" "$group" "$fullname"
        fi
    done < "$csv_file"
}

# Main execution
echo "Syncing users from CSV files..."

# Process regular user CSV files
process_csv "/root/users_csv/hncwebsa.csv" "webdev"
process_csv "/root/users_csv/hndwebsa.csv" "webdev"
process_csv "/root/users_csv/hncwebmr.csv" "webdev"
process_csv "/root/users_csv/hndwebmr.csv" "webdev"
process_csv "/root/users_csv/hnccssa.csv" "compsc"
process_csv "/root/users_csv/hndcssa.csv" "compsc"
process_csv "/root/users_csv/hnccsmr.csv" "compsc"
process_csv "/root/users_csv/hndcsmr.csv" "compsc"

# Process admin user CSV file
process_csv "/root/users_csv/admin_users.csv" "admin"

echo "User synchronization completed."

# Ensure changes take effect for SSH
exec /usr/sbin/sshd -D

