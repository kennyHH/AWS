#!/bin/bash

# Check if setup has already been done
if [ ! -f "/setup_flag/setup_done" ]; then
    echo "Running initial setup..."
    
    # Run setup scripts
    sh /root/setup_users_and_databases.sh
    sh /root/create_vhosts.sh
    
    echo "Initial setup completed."
else
    echo "Setup already done. Skipping setup scripts."
fi

# Start SSH service
service ssh start

# Start Apache in foreground
apache2-foreground
