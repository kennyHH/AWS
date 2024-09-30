FROM php:8.3-apache

# Install necessary packages
RUN apt-get update && apt-get install -y \
    openssh-server \
    default-mysql-client \
    nano \
    sudo \
    cron \
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
COPY ./scripts/scan_and_move_large_files.sh /root/scan_and_move_large_files.sh
COPY ./scripts/clear_tmp_folder.sh /root/clear_tmp_folder.sh

# Copy users
COPY ./users_csv/csv /root/users_csv

# Set correct permissions for files
RUN chmod 700 /root/setup_users_and_databases.sh /root/create_vhosts.sh /root/create_admin_users.sh /root/scan_and_move_large_files.sh /root/clear_tmp_folder.sh

# Copy config files 
COPY ./config/sshd_config /etc/ssh/sshd_config
COPY ./config/phpmyadmin-proxy.conf /etc/apache2/sites-available/phpmyadmin-proxy.conf

# Configure Apache
RUN echo "IncludeOptional /etc/apache2/sites-enabled/*.conf" >> /etc/apache2/apache2.conf

# Enable Apache modules
RUN a2enmod proxy proxy_http rewrite

# Generate users
RUN /root/setup_users_and_databases.sh
RUN /root/create_admin_users.sh
RUN /root/create_vhosts.sh

# Apache setup
RUN a2enmod proxy proxy_http rewrite 
RUN a2dissite 000-default
RUN a2ensite phpmyadmin-proxy
CMD ["apachectl", "-D", "FOREGROUND"]

# Set up cron jobs
RUN echo "0 0 * * * /root/scan_and_move_large_files.sh" > /etc/cron.d/scan_large_files
RUN echo "0 0 * * 0 /root/clear_tmp_folder.sh" > /etc/cron.d/clear_tmp
RUN chmod 0644 /etc/cron.d/scan_large_files /etc/cron.d/clear_tmp

# Combine cron jobs into a single crontab file
RUN cat /etc/cron.d/scan_large_files /etc/cron.d/clear_tmp > /etc/cron.d/combined_crontab
RUN crontab /etc/cron.d/combined_crontab

# Copy the startup script
COPY ./scripts/startup.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/startup.sh

# Use the startup script as the entry point
CMD ["/usr/local/bin/startup.sh"]

ENV MYSQL_ROOT_PASSWORD "really" 

