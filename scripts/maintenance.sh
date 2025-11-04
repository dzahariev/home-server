#!/bin/bash

dockerHubIsUp() {
  docker pull alpine:3.18 > /dev/null
}

echo "Updates the host packages ..."
sudo apt-get clean -y
sudo apt-get update
sudo apt-get dist-upgrade -y
sudo apt-get upgrade -y
sudo apt-get autoremove -y
echo "Host packages are updated!"

echo "Check if DockerHub can be reached ..."
if ! dockerHubIsUp ; then
	echo "DockerHub canot be reached, will not update images."
else
	echo "Backup of compose file ..."
 	cp /home/ubuntu/home-server/docker-compose.yml /home/ubuntu/home-server/docker-compose.yml.old
 	echo "Old compose file is saved!"

	echo "Gets update from GitHub ..."
	cd /home/ubuntu/home-server
	git pull
	echo "Updates arefetched from GitHub!"

	echo "Pull new containers ..."
 	cd /home/ubuntu/home-server
 	docker compose --env-file .env.server pull
 	echo "Containers are pulled!"

	echo "Prepare compose file for stopping ..."
 	mv /home/ubuntu/home-server/docker-compose.yml /home/ubuntu/home-server/docker-compose.yml.new
 	mv /home/ubuntu/home-server/docker-compose.yml.old /home/ubuntu/home-server/docker-compose.yml
 	echo "Old compose file is restored!"

	echo "Stops the containers ..."
 	cd /home/ubuntu/home-server
 	docker compose --env-file .env.server down --remove-orphans
 	echo "Containers are stopped!"
	
	echo "Prepare compose file for starting ..."
 	rm /home/ubuntu/home-server/docker-compose.yml
 	mv /home/ubuntu/home-server/docker-compose.yml.new /home/ubuntu/home-server/docker-compose.yml
 	echo "New compose file is restored!"

	echo "Starts the containers ..."
	cd /home/ubuntu/home-server
	docker compose --env-file .env.server up -d
	echo "Containers are started!"

	echo "Cleanup images ..."
	cd /home/ubuntu/home-server
	docker system prune -af
	echo "Images are cleared!"
fi

echo "Checking if reboot is required ..."
if [ -f /var/run/reboot-required ]; then
	echo "Rebooting the host!"
	sudo /sbin/reboot
else
	echo "Reboot is not required."
fi
