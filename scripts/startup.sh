#!/bin/bash

# Start SSH and cron service
service ssh start
service cron start

# Start Apache in the foreground
apache2-foreground

