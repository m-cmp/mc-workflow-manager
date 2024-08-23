#!/bin/bash

echo "======================================================================================"
echo "NGINX RUN START"
echo "======================================================================================"
cd $HOME
if [ ! -d mcmp ]; then
  mkdir -p $HOME/mcmp/oss/nginx
  chown 1000:1000 $HOME/mcmp/oss/nginx
  echo "Create jenkins dir"
fi

LGREEN='\033[1;32m'
NC='\033[0m' # No Color

APP_NAME=nginx
APP_IMAGE=nginx

echo -e "docker pull ${LGREEN} $APP_NAME ${NC} image."
sudo docker pull $APP_IMAGE

echo -e "Start ${LGREEN} $APP_NAME ${NC}"

HOME=$HOME
sudo docker run -itd \
        -p 8080:8080 \
        -v $HOME/mcmp/git/mc-workflow-manager/src/resources/static/dist:/usr/share/nginx/html/ \
        -v $HOME/mcmp/git/mc-workflow-manager/workflowFE/nginx_conf/:/etc/nginx/conf.d/ \
        --name nginx \
        -u root \
$APP_IMAGE

# 컨테이너가 완전히 시작될 때까지 잠시 대기
echo "Waiting for Jenkins to start..."
sleep 10

echo "======================================================================================"
echo "NGINX RUN FINISH"
echo "======================================================================================"