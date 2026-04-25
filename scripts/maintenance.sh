#!/bin/bash

ARCHIVE_DIR="/media/ubuntu/HDD/Media/archives"
DATA_DIR="/media/ubuntu/HDD/Media/data"

dockerHubIsUp() {
  docker pull alpine:3.18 > /dev/null
}

shouldCreateArchive() {
  local CURRENT_YYMM=$(date +%y%m)
  local EXISTING=$(find "${ARCHIVE_DIR}" -maxdepth 1 -name "${CURRENT_YYMM}*data.tar.bz2" 2>/dev/null)
  [[ -z "$EXISTING" ]]
}

createArchive() {
  local ARCHIVE_BASE="$(date +%y%m%d)data"
  local ARCHIVE_NAME="${ARCHIVE_BASE}.tar.bz2"
  local WRAPPER_DIR="${ARCHIVE_DIR}/${ARCHIVE_BASE}"
  local ARCHIVE_PATH="${WRAPPER_DIR}/${ARCHIVE_NAME}"

  echo "Creating archive ${ARCHIVE_PATH} ..."
  mkdir -p "${WRAPPER_DIR}"
  tar -cjf "${ARCHIVE_PATH}" -C "$(dirname "${DATA_DIR}")" "$(basename "${DATA_DIR}")"

  if [[ $? -eq 0 ]]; then
    echo "Archive created successfully!"

    # Delete previous archive folders (keep only the new one)
    for old_dir in "${ARCHIVE_DIR}"/*/; do
      [[ -d "$old_dir" ]] || continue
      if [[ "$old_dir" != "${WRAPPER_DIR}/" ]]; then
        echo "Deleting old archive folder: $old_dir"
        rm -rf "$old_dir"
      fi
    done
    echo "Previous archives deleted!"

    # Write lastFullArchive with full path to the wrapper folder
    echo "${WRAPPER_DIR}" > "${ARCHIVE_DIR}/lastFullArchive"
    echo "lastFullArchive updated with: ${WRAPPER_DIR}"
  else
    echo "Archive creation failed!"
    rm -rf "${WRAPPER_DIR}"
  fi
}

echo "Updates the host packages ..."
sudo apt-get clean -y
sudo apt-get update
sudo apt-get dist-upgrade -y
sudo apt-get upgrade -y
sudo apt-get autoremove -y
echo "Host packages are updated!"

NEED_ARCHIVE=false
NEED_UPDATE=false

echo "Checking if monthly archive is needed ..."
if shouldCreateArchive; then
  NEED_ARCHIVE=true
  echo "Monthly archive will be created."
else
  echo "Monthly archive already exists, skipping."
fi

echo "Check if DockerHub can be reached ..."
if dockerHubIsUp; then
  NEED_UPDATE=true
  echo "DockerHub is reachable, will update containers."
else
  echo "DockerHub cannot be reached, will not update images."
fi

if $NEED_UPDATE; then
  echo "Backup of compose file ..."
  cp /home/ubuntu/home-server/docker-compose.yml /home/ubuntu/home-server/docker-compose.yml.old
  echo "Old compose file is saved!"

  echo "Gets update from GitHub ..."
  cd /home/ubuntu/home-server
  git pull
  echo "Updates are fetched from GitHub!"

  echo "Pull new containers ..."
  cd /home/ubuntu/home-server
  docker compose --env-file .env.server pull
  echo "Containers are pulled!"
fi

if $NEED_ARCHIVE || $NEED_UPDATE; then
  if $NEED_UPDATE; then
    echo "Prepare compose file for stopping ..."
    mv /home/ubuntu/home-server/docker-compose.yml /home/ubuntu/home-server/docker-compose.yml.new
    mv /home/ubuntu/home-server/docker-compose.yml.old /home/ubuntu/home-server/docker-compose.yml
    echo "Old compose file is restored!"
  fi

  echo "Stops the containers ..."
  cd /home/ubuntu/home-server
  docker compose --env-file .env.server down --remove-orphans
  echo "Containers are stopped!"

  if $NEED_ARCHIVE; then
    createArchive
  fi

  if $NEED_UPDATE; then
    echo "Prepare compose file for starting ..."
    rm /home/ubuntu/home-server/docker-compose.yml
    mv /home/ubuntu/home-server/docker-compose.yml.new /home/ubuntu/home-server/docker-compose.yml
    echo "New compose file is restored!"
  fi

  echo "Starts the containers ..."
  cd /home/ubuntu/home-server
  docker compose --env-file .env.server up -d
  echo "Containers are started!"

  if $NEED_UPDATE; then
    echo "Cleanup images ..."
    cd /home/ubuntu/home-server
    docker system prune -af
    echo "Images are cleared!"
  fi
fi

echo "Checking if reboot is required ..."
if [ -f /var/run/reboot-required ]; then
  echo "Rebooting the host!"
  sudo /sbin/reboot
else
  echo "Reboot is not required."
fi
