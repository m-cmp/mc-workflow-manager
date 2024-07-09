#!/bin/bash

APP_NAME=mc-workflow-manager
APP_IMAGE=mc-workflow-manager:v0.0.1

echo -e "Start ${LGREEN} $APP_NAME ${NC}"

DATABASE_URL=$(curl -s ifconfig.me)

echo ${DATABASE_URL}

sudo docker run -itd \
        -p 18083:18083 \
        -e DB_ID=root \
        -e DB_PW=mcmp \
        -e DB_URL=${DATABASE_URL}:3306/mcmp \
        --name mc-workflow-manager \
$APP_IMAGE
