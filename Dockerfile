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
COPY ./scripts/setup_users_and_databases.sh /root/setup_users_and_databases.sh
COPY ./scripts/create_vhosts.sh /root/create_vhosts.sh
COPY ./scripts/start_services.sh /root/start_services.sh
COPY ./users_csv/hnccssa.csv /root/hnccssa.csv
COPY ./users_csv/hncwebsa.csv /root/hncwebsa.csv
COPY ./users_csv/hncothers.csv /root/hncothers.csv

# Set correct permissions for files
RUN chmod 700 /root/setup_users_and_databases.sh /root/create_vhosts.sh /root/start_services.sh
RUN chmod 700 /root/hncothers.csv /root/hncwebsa.csv /root/hnccssa.csv

# Create the groups
RUN groupadd hncwebsa && usermod -aG hncwebsa www-data
RUN groupadd hnccssa
RUN groupadd hncothers

# Create necessary directories
RUN mkdir /setup_flag 

# Set the entrypoint
ENTRYPOINT ["/root/start_services.sh"]
# Set the volume for the setup flag
#VOLUME ["/setup_flag"]
