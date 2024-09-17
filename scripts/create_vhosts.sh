#!/bin/sh

# Create the apache directory if it doesn't exist
mkdir -p /etc/apache2/sites-enabled

# Create the main VirtualHost configuration
cat > "/etc/apache2/sites-enabled/000-default.conf" << EOF
<VirtualHost *:80>
    ServerName localhost
    DocumentRoot "/var/www/html"

    <Directory "/var/www/html">
        Options FollowSymLinks
        AllowOverride All
        Require all granted
    </Directory>

    ErrorLog "\${APACHE_LOG_DIR}/error.log"
    CustomLog "\${APACHE_LOG_DIR}/access.log" combined

    # Include student-specific configurations
    IncludeOptional /etc/apache2/sites-enabled/student*.conf

    # Include admin-specific configurations
    IncludeOptional /etc/apache2/sites-enabled/admin*.conf
</VirtualHost>
EOF

# Function to process CSV file and create configurations for students
process_student_csv() {
    csv_file=$1
    i=$2
    
    while IFS=',' read -r username _; do
        # Skip the header line and empty usernames
        if [ "$username" != "USERNAME" ] && [ -n "$username" ]; then
            # Create the student-specific configuration file
            cat > "/etc/apache2/sites-enabled/student$i.conf" << EOF
Alias /$username "/home/webdev/$username/website"
<Directory "/home/webdev/$username/website">
    Options FollowSymLinks
    AllowOverride All
    Require all granted
</Directory>
EOF
            i=$((i+1))
        fi
    done < "$csv_file"
    
    echo $i
}

# Function to process CSV file and create configurations for admins
process_admin_csv() {
    csv_file=$1
    i=$2
    
    while IFS=',' read -r username _; do
        # Skip the header line and empty usernames
        if [ "$username" != "USERNAME" ] && [ -n "$username" ]; then
            # Create the admin-specific configuration file
            cat > "/etc/apache2/sites-enabled/admin$i.conf" << EOF
Alias /$username "/home/admins/$username/website"
<Directory "/home/admins/$username/website">
    Options FollowSymLinks
    AllowOverride All
    Require all granted
</Directory>
EOF
            # Set appropriate permissions for admin directories
            mkdir -p "/home/admins/$username/website"
            chown -R $username:admin "/home/admins/$username"
            chmod 750 "/home/admins/$username"
            chmod 755 "/home/admins/$username/website"
            
            i=$((i+1))
        fi
    done < "$csv_file"
    
    echo $i
}

# Process all the required student CSV files
next_index=1
for csv_file in \
    "/root/users_csv/hncwebsa.csv" \
    "/root/users_csv/hndwebsa.csv" \
    "/root/users_csv/hndwebmr.csv" \
    "/root/users_csv/hncwebmr.csv"
do
    if [ -f "$csv_file" ]; then
        echo "Processing student file: $csv_file"
        next_index=$(process_student_csv "$csv_file" $next_index)
    else
        echo "Warning: $csv_file not found"
    fi
done

# Process the admin CSV file
admin_csv="/root/users_csv/admin_users.csv"
if [ -f "$admin_csv" ]; then
    echo "Processing admin file: $admin_csv"
    admin_count=$(process_admin_csv "$admin_csv" 1)
    echo "Created $((admin_count - 1)) admin configurations."
else
    echo "Warning: $admin_csv not found"
fi

# Ensure Apache can read the student and admin directories
usermod -aG webdev www-data
usermod -aG admin www-data

# Create admins group if it doesn't exist
groupadd -f admin

echo "Virtual host configuration completed. Created $((next_index - 1)) student configurations and $((admin_count - 1)) admin configurations."
