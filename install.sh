#!/bin/bash


#Pre-Flight
apt update && apt upgrade -y
reboot

#Harden Host
apt install -y iptables iptables-persistent cronie vim net-tools iputils-ping \
	wireguard wireguard-tools zpaq backblaze-b2
cat > /etc/iptables/rules.v4 <<EOF
> *filter
:INPUT DROP [0:0]
:FORWARD DROP [0:0]
:OUTPUT ACCEPT [0:0]

# Allow loopback traffic
-A INPUT -i lo -j ACCEPT

# Allow established and related traffic
-A INPUT -m state --state RELATED,ESTABLISHED -j ACCEPT

# Allow SSH (port 22)
-A INPUT -p tcp --dport 22 -j ACCEPT

# Allow HTTP and HTTPS
-A INPUT -p tcp --dport 80 -j ACCEPT
-A INPUT -p tcp --dport 443 -j ACCEPT

COMMIT
EOF


iptables-restore < /etc/iptables/rules.v4
systemctl enable netfilter-persistent


# Setup Cron
timedatectl set-timezone America/New_York
echo '0   5  *  *  0     root     reboot' >> /etc/crontab
echo '30  4  *  *  0     root     apt update -y && apt upgrade -y' >> /etc/crontab
echo '0   3  *  *  1     root     /bin/bash /opt/docker/mariadb/backup.sh' >> /etc/crontab
echo '0   7  *  *  1     root     /root/prodweb/backup.sh' >> /etc/crontab

systemctl enable --now cronie

# Setup Docker
# Add Docker's official GPG key:
sudo apt-get update
sudo apt-get install ca-certificates curl
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

# Add the repository to Apt sources:
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update
sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

mkdir -p /opt/docker/mariadb
mkdir /opt/docker-data
cd /opt/docker/mariadb
