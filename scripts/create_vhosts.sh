#!/bin/bash

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
</VirtualHost>
EOF

# Function to process CSV file and create configurations
process_csv() {
    local csv_file=$1
    local group=$2
    local i=$3
    
    while IFS=',' read -r username _; do
        # Skip the header line
        if [ "$username" != "username" ]; then
            # Create the student-specific configuration file
            cat > "/etc/apache2/sites-enabled/student$i.conf" << EOF
Alias /$username "/home/$username/website"
<Directory "/home/$username/website">
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

# Process hncwebsa users
next_index=$(process_csv "/root/users_csv/hncwebsa.csv" "hncwebsa" 1)

# Process hncwebmr users
process_csv "/root/users_csv/hncwebmr.csv" "hncwebmr" $next_index

# Ensure Apache can read the student directories
usermod -aG hncwebsa www-data
usermod -aG hncwebmr www-data
