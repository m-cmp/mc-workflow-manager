#!/bin/bash

APP_NAME=mc-workflow-manager
APP_IMAGE=mc-workflow-manager:v0.0.1

echo -e "Start ${LGREEN} $APP_NAME ${NC}"

docker run -itd \
        -p 18084:18084 \
        -e DB_USER_NAME=root \
        -e DB_PWD=mcmp \
        -e DB_URL=localhost:3306 \
        --name mc-workflow-manager \ 
$APP_IMAGE
