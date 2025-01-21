#!/bin/bash

mgmtUser=$1
appUser=$2
app1=$3
app1IP=$4
app2=$5
app2IP=$6


chmod 600 /home/$mgmtUser/.ssh/id_rsa

echo "# SSH config for $app1" > .ssh/config
echo "Host $app1" >> .ssh/config
echo "  HostName $app1IP" >> .ssh/config
echo "  User $appUser" >> .ssh/config
echo "  Port 22" >> .ssh/config
echo "" >> .ssh/config
echo "# SSH config for $app2" >> .ssh/config
echo "Host $app2" >> .ssh/config
echo "  HostName $app2IP" >> .ssh/config
echo "  User $appUser" >> .ssh/config
echo "  Port 22" >> .ssh/config
echo "" >> .ssh/config

echo "" >> .bashrc
echo "# SSH alias configs" >> .bashrc
echo "alias $app1=\"ssh $app1\"" >> .bashrc
echo "alias $app2=\"ssh $app2\"" >> .bashrc

sudo wget -O /usr/share/keyrings/jenkins-keyring.asc \
  https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key
echo "deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc]" \
  https://pkg.jenkins.io/debian-stable binary/ | sudo tee \
  /etc/apt/sources.list.d/jenkins.list > /dev/null
sudo apt-get update -y
sudo apt-get install jenkins -y

sudo apt update -y
sudo apt install fontconfig openjdk-17-jre -y

sudo iptables -I INPUT 1 -p tcp --dport 8443 -j ACCEPT
sudo iptables -I INPUT 1 -p tcp --dport 8080 -j ACCEPT
sudo iptables -I INPUT 1 -p tcp --dport 443 -j ACCEPT
sudo iptables -I INPUT 1 -p tcp --dport 80 -j ACCEPT

# Add Docker's official GPG key:
sudo apt-get update -y
sudo apt-get install ca-certificates curl -y
sudo install -m 0755 -d /etc/apt/keyrings -y
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

# Add the repository to Apt sources:
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update -y

# Install Docker
sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin -y

sudo usermod -a -G docker jenkins

sudo apt-get update -y
sudo apt-get upgrade -y

sudo systemctl enable jenkins
sudo systemctl start jenkins
