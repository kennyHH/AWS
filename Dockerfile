FROM php:8.3-apache

# Install necessary packages
RUN apt-get update && apt-get install -y \
    openssh-server \
    default-mysql-client \
    nano \
    sudo \
    cron \
    && docker-php-ext-install mysqli pdo pdo_mysql

# SSH CONFIG
RUN mkdir -p /etc/ssh/logs && chown root:root /etc/ssh/logs && chmod 700 /etc/ssh/logs
CMD ["/usr/sbin/sshd", "-D", "-E", "/etc/ssh/logs/auth.log"]

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

# Copy users
COPY ./users_csv/csv /root/users_csv

# Set correct permissions for files
RUN chmod 700 /root/setup_users_and_databases.sh /root/create_vhosts.sh /root/create_admin_users.sh

# Copy config files 
COPY ./config/sshd_config /etc/ssh/sshd_config
COPY ./config/phpmyadmin-proxy.conf /etc/apache2/sites-available/phpmyadmin-proxy.conf

# Configure Apache
RUN echo "IncludeOptional /etc/apache2/sites-enabled/*.conf" >> /etc/apache2/apache2.conf

# Enable Apache modules
RUN a2enmod proxy proxy_http rewrite

# Create necessary directories
RUN mkdir /setup_flag 

# Generate users
RUN /root/setup_users_and_databases.sh
RUN /root/create_admin_users.sh
RUN /root/create_vhosts.sh

# Apache setup
RUN a2enmod proxy proxy_http rewrite 
RUN a2dissite 000-default
RUN a2ensite phpmyadmin-proxy
CMD ["apachectl", "-D", "FOREGROUND"]

# Copy the startup script
COPY ./scripts/startup.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/startup.sh

# Use the startup script as the entry point
CMD ["/usr/local/bin/startup.sh"]

ENV MYSQL_ROOT_PASSWORD "really" 

