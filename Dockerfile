FROM php:8.3-apache

# Install necessary packages
RUN apt-get update && apt-get install -y \
    openssh-server \
    default-mysql-client \
    nano \
    sudo \
    && docker-php-ext-install mysqli pdo pdo_mysql


# Configure SSH
RUN mkdir /var/run/sshd
RUN sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin no/' /etc/ssh/sshd_config

# Create the groups
RUN groupadd webdev && usermod -aG webdev www-data
RUN groupadd compsc
RUN groupadd admin

# Copy scripts
COPY ./scripts/setup_users_and_databases.sh /root/setup_users_and_databases.sh
COPY ./scripts/create_vhosts.sh /root/create_vhosts.sh
COPY ./scripts/create_admin_users.sh /root/create_admin_users.sh
COPY ./scripts/start_services.sh /root/start_services.sh
COPY ./scripts/sync_users.sh /root/sync_users.sh

# Set correct permissions for files
RUN chmod 700 /root/setup_users_and_databases.sh /root/create_vhosts.sh /root/start_services.sh /root/sync_users.sh /root/create_admin_users.sh

# Copy config files 
COPY ./config/sshd_config /etc/ssh/sshd_config
COPY ./config/phpmyadmin-proxy.conf /etc/apache2/sites-available/phpmyadmin-proxy.conf

# Configure Apache
RUN echo "IncludeOptional /etc/apache2/sites-enabled/*.conf" >> /etc/apache2/apache2.conf

# Enable Apache modules
RUN a2enmod proxy proxy_http rewrite

# Create necessary directories
RUN mkdir /setup_flag 

# Set the entrypoint
ENTRYPOINT ["/root/start_services.sh"]
