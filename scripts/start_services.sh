#!/bin/bash

# Check if setup has already been done
if [ ! -f "/setup_flag/setup_done" ]; then
    echo "Running initial setup..."
    
    # Run setup scripts
    sh /root/setup_users_and_databases.sh
    sh /root/create_admin_users.sh
    sh /root/create_vhosts.sh
    a2dissite 000-default
    a2enmod proxy proxy_http rewrite
    a2ensite phpmyadmin-proxy
    echo "Initial setup completed."
else
    echo "Setup already done. Syncing users..."
    sh /root/sync_users.sh
fi

# Start SSH service
service ssh start

# Ensure Apache is configured correctly
a2enmod proxy proxy_http rewrite
a2ensite phpmyadmin-proxy

# Start Apache in foreground
echo "Started apache2 service"
exec apache2-foreground
