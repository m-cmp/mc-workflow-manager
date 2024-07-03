#!/bin/bash

APP_NAME=mc-workflow-manager
APP_IMAGE=mc-workflow-manager:v0.0.1

echo -e "Start ${LGREEN} $APP_NAME ${NC}"

sudo docker run -itd \
        -p 18083:18083 \
        -e DB_USER_NAME=root \
        -e DB_PWD=mcmp \
        -e DB_URL=localhost:3306 \
        --name mc-workflow-manager \
$APP_IMAGE
