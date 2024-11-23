#!/bin/bash

cd "$(dirname "$0")" || exit
#Load credentials
source .env

#Systemfiles
mkdir -p /opt/docker/system
cp /etc/wireguard/wg0.conf /opt/docker/system
cp /etc/iptables/rules.v4 /opt/docker/system

#Prepare Backup
mkdir -p /opt/docker-backup
filename="cloud-dockerbackup$(date +%Y%m%d)"
zpaq a /opt/docker-backup/backup.zpaq /opt/docker

backblaze-b2 authorize-account ${bcred1} ${bcred2}
backblaze-b2 upload-file --noProgress HeroWellHorizon /opt/docker-backup/backup.zpaq ${filename}
