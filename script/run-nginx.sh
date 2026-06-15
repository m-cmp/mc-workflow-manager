#!/bin/bash

echo "======================================================================================"
echo "NGINX RUN START"
echo "======================================================================================"

cd $HOME

# Check and create the mcmp directory.
if [ ! -d "$HOME/mcmp/oss/nginx" ]; then
  mkdir -p "$HOME/mcmp/oss/nginx"
  chown 1000:1000 "$HOME/mcmp/oss/nginx"
  echo "Created mcmp/nginx directory"
fi

# Color code settings
LGREEN='\033[1;32m'
NC='\033[0m' # No Color

# Application name and image
APP_NAME=nginx
APP_IMAGE=nginx

# Pull Docker image
echo -e "docker pull ${LGREEN}${APP_NAME}${NC} image."
sudo docker pull $APP_IMAGE

# Stop and remove an existing nginx container.
if sudo docker ps -a | grep -q nginx; then
  sudo docker stop nginx
  sudo docker rm nginx
fi

# Run Docker container
echo -e "Start ${LGREEN}${APP_NAME}${NC}"

sudo docker run -itd \
  -p 8080:80 \
  -v "$HOME/mcmp/git/mc-workflow-manager/src/main/resources/static/dist:/usr/share/nginx/html/" \
  -v "$HOME/mcmp/git/mc-workflow-manager/workflowFE/nginx/:/etc/nginx/conf.d/" \
  --name nginx \
  -u root \
  $APP_IMAGE

# Wait briefly until the container is fully started.
echo "Waiting for NGINX to start..."
sleep 10

# Check mounted volumes and NGINX status.
echo "Checking mounted volumes..."
sudo docker inspect nginx | grep '"Source":' | grep -E 'html|conf.d'

echo "======================================================================================"
echo "NGINX RUN FINISH"
echo "======================================================================================"
