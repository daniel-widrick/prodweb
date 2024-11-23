#!/bin/bash


source /opt/docker/mariadb/.env
dbcontainer=$(docker ps | grep mariadb:latest | awk '{print $1}')


mkdir -p /opt/docker-data/db-backups/

backup_date=$(date +%Y%m%d_%H%M%S)

docker exec $dbcontainer mariadb-dump -p${MYSQL_ROOT_PASSWORD} --all-databases | gzip > /opt/docker-data/db-backups/db_${backup_date}.sql.gz

cp /opt/docker-data/db-backups/db_${backup_date}.sql.gz /opt/docker/db.sql.gz

#Clean up
find /opt/docker-data/db-backups/ -type f -mtime +365 -exec rm -f {} +
