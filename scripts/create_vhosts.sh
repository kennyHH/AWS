#!/bin/bash

# Create the apache directory if it doesn't exist
mkdir -p /etc/apache2/sites-available
mkdir -p /etc/apache2/sites-enabled

# Create the main VirtualHost configuration
cat > "/etc/apache2/sites-available/000-default.conf" << EOF
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

    # Student website configurations
EOF

# Add student-specific configurations to 000-default.conf
for i in $(seq 1 25); do
    username="hncwebsa$i"
    cat >> "/etc/apache2/sites-available/000-default.conf" << EOF

    Alias /hncwebsa$i "/home/$username/website"
    <Directory "/home/$username/website">
        Options FollowSymLinks
        AllowOverride All
        Require all granted
    </Directory>
EOF
done

# Close the VirtualHost block
echo "</VirtualHost>" >> "/etc/apache2/sites-available/000-default.conf"

# Enable the default site
ln -sf /etc/apache2/sites-available/000-default.conf /etc/apache2/sites-enabled/000-default.conf

# Remove any existing student-specific conf files to avoid conflicts
rm -f /etc/apache2/sites-enabled/student*.conf

# Ensure Apache can read the student directories
usermod -aG hncwebsa www-data

# Enable necessary Apache modules
a2enmod rewrite

# Restart Apache to apply changes
service apache2 restart

echo "Apache configuration completed."
