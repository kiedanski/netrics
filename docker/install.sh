#!/usr/bin/env bash
PROJECT_DIR="$HOME/netrics-deployment"
# Setup basic packages

printf "${GREEN}Installing packages from manager ... ${NC} \n \n \n"
sudo apt-get update && apt-get install -y vim curl unzip inotify-tools uidmap


# Setup docker

printf "${GREEN}Installing latest Docker... ${NC} \n \n \n"

# Update the release list
if ! command -v docker &> /dev/null
then
	echo   "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/debian \
		  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
	curl -sSL https://get.docker.com | sh
	dockerd-rootless-setuptool.sh install # Add rootless
else
	printf "${RED}Docker is already installed ${NC} \n \n"
fi

# Installing AWS CLI

if ! command -v aws &> /dev/null
then
	curl "https://awscli.amazonaws.com/awscli-exe-linux-aarch64.zip" -o "awscliv2.zip"
	unzip awscliv2.zip
	sudo ./aws/install
	rm -rf aws awscliv2.zip
else
	printf "${RED}AWS CLI already installed ${NC} \n \n"
fi


 printf "${GREEN}Downloading docker compose... ${NC} \n \n \n"
 mkdir -p $PROJECT_DIR
 cd $PROJECT_DIR
 mkdir -p data
 
 curl -o docker-compose.yml https://raw.githubusercontent.com/kiedanski/netrics/adding-docker/docker/docker-compose.yml
 curl -o notifys3 https://raw.githubusercontent.com/kiedanski/netrics/adding-docker/docker/notifys3


# Create service for docker compose
sudo tee /etc/systemd/system/docker-compose-app.service > /dev/null <<EOT
# /etc/systemd/system/docker-compose-app.service

[Unit]
Description=Docker Compose Application Service
Requires=docker.service
After=docker.service
After=docker.socket
Requires=docker.socket
Restart=always

[Service]
Type=oneshot
RemainAfterExit=yes
WorkingDirectory=/home/pi/netrics-deployment
ExecStart=/usr/bin/docker compose up -d
ExecStop=/usr/bin/docker compose down

[Install]
WantedBy=multi-user.target
EOT


# Create service to upload to s3
sudo tee /etc/systemd/system/inotifys3.service > /dev/null <<EOT
[Unit]
Description = Run inotifywait in backgoround

[Service]
User=pi
Group=pi
ExecStart=/bin/bash /home/pi/netrics-deployment/notifys3
RestartSec=10

[Install]
WantedBy=multi-user.target
EOT

sudo systemctl enable inotifys3
sudo systemctl start inotifys3
sudo systemctl enable docker-compose-app
sudo systemctl start docker-compose-app
