#!/bin/bash


source /opt/docker/mariadb/.env
dbcontainer=$(docker ps | grep mariadb:latest | awk '{print $1}')


mkdir -p /opt/docker-data/db-backups/
docker exec $dbcontainer mariadb-dump -p${MYSQL_ROOT_PASSWORD} --all-databases | gzip > /opt/docker-data/db-backups/db_$(date +%Y%m%d_%H%M%S).sql.gz
