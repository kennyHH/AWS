FROM php:8.3-apache

# Install necessary packages
RUN apt-get update && apt-get install -y \
    openssh-server \
    default-mysql-client \
    && docker-php-ext-install mysqli pdo pdo_mysql

# Configure Apache
RUN echo "IncludeOptional /etc/apache2/sites-enabled/*.conf" >> /etc/apache2/apache2.conf

# Configure SSH
RUN mkdir /var/run/sshd
RUN sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin no/' /etc/ssh/sshd_config

# Copy scripts
COPY ./scripts/setup_users_and_databases.sh /setup_users_and_databases.sh
COPY ./scripts/create_vhosts.sh /create_vhosts.sh
COPY ./scripts/start_services.sh /start_services.sh
COPY ./hnccssa.csv /hnccssa.csv
COPY ./hncwebsa.csv /hncwebsa.csv
COPY ./hncothers.csv /hncothers.csv

# Make scripts executable
RUN chmod +x /setup_users_and_databases.sh /create_vhosts.sh /start_services.sh /

# Create the groups
RUN groupadd hncwebsa && usermod -aG hncwebsa www-data
RUN groupadd hnccssa
RUN groupadd hncothers

# Create necessary directories
RUN mkdir /setup_flag 

# Set the entrypoint
ENTRYPOINT ["/start_services.sh"]
# Set the default command to start services
# CMD ["/start_services.sh"]
# Set the volume for the setup flag
VOLUME ["/setup_flag"]
