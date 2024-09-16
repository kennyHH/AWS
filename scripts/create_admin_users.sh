#!/bin/bash

# Create admin group if it doesn't exist
if ! getent group admin > /dev/null 2>&1; then
    groupadd admin
    echo "Created admin group"
fi

# Function to create administrator user and set up their environment
create_admin_user() {
    local username=$1
    local password=$2
    local fullname=$3

    # Create the admin directory if it doesn't exist
    mkdir -p /home/admins
    chmod 755 /home/admins

    # Check if the user already exists
    if ! id -u "${username}" >/dev/null 2>&1; then
        # Create user's system account with home directory in /home/admins
        useradd -m -d "/home/admins/${username}" -s /bin/bash -g admin "${username}"
        # Set password
        echo "${username}:${password}" | chpasswd
        echo "Created admin user: ${username}"

        # Add user to sudo group
        usermod -aG sudo "${username}"
        echo "Added ${username} to sudo group"

        # Set up sudo access without password (optional, uncomment if needed)
        # echo "${username} ALL=(ALL) NOPASSWD: ALL" > "/etc/sudoers.d/${username}"
        # chmod 0440 "/etc/sudoers.d/${username}"

        # Create .ssh directory and set permissions
        mkdir -p "/home/admins/${username}/.ssh"
        chmod 700 "/home/admins/${username}/.ssh"
        chown "${username}:admin" "/home/admins/${username}/.ssh"

        # Set correct permissions for admin home directory
        chmod 750 "/home/admins/${username}"

        # Create MySQL user and grant privileges
        mysql -h mysql -u root -p"${MYSQL_ROOT_PASSWORD}" <<EOF
CREATE USER '${username}'@'%' IDENTIFIED BY '${password}';
GRANT ALL PRIVILEGES ON *.* TO '${username}'@'%' WITH GRANT OPTION;
FLUSH PRIVILEGES;
EOF
        echo "Created MySQL user with full privileges: ${username}"

    else
        echo "User ${username} already exists. Updating group, sudo access, and MySQL privileges."
        usermod -g admin "${username}"
        usermod -aG sudo "${username}"

        # Update MySQL user password and privileges
        mysql -h mysql -u root -p"${MYSQL_ROOT_PASSWORD}" <<EOF
ALTER USER '${username}'@'%' IDENTIFIED BY '${password}';
GRANT ALL PRIVILEGES ON *.* TO '${username}'@'%' WITH GRANT OPTION;
FLUSH PRIVILEGES;
EOF
        echo "Updated MySQL user privileges: ${username}"
    fi
}

# Main execution
echo "Creating administrator accounts from CSV file..."

# Specify the path to your CSV file
CSV_FILE="/root/users_csv/admin_users.csv"

# Check if the CSV file exists
if [ ! -f "$CSV_FILE" ]; then
    echo "Error: CSV file not found at $CSV_FILE"
    exit 1
fi

# Process the CSV file
while IFS=',' read -r username password fullname
do
    # Skip the header line
    if [ "$username" != "USERNAME" ]; then
        create_admin_user "$username" "$password" "$fullname"
    fi
done < "$CSV_FILE"

echo "Administrator account creation completed."

# Ensure changes take effect
#exec /usr/sbin/sshd -D
