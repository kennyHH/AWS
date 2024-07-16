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

# Loop through student numbers 1 to 25
for i in $(seq 1 25); do
    username="hncwebsa$i"
    
    # Create the student-specific configuration file
    cat > "/etc/apache2/sites-enabled/student$i.conf" << EOF
Alias /$username "/home/$username/website"
<Directory "/home/$username/website">
    Options FollowSymLinks
    AllowOverride All
    Require all granted
</Directory>
EOF
done

# Ensure Apache can read the student directories
usermod -aG hncwebsa www-data
