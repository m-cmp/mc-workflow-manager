#!/bin/bash

echo "======================================================================================"
echo "WORKFLOW MANAGER RUN START"
echo "======================================================================================"

# 현재 프로젝트 경로
PROJECT_PATH=${PROJECT_ROOT}
#DB 볼륨 생성
mkdir ${PROJECT_PATH}/DB
DB_VOLUME_PATH=${PROJECT_PATH}/DB

# Application 명
APP_NAME=mc-workflow-manager
# Application 이미지 명
APP_IMAGE=mc-workflow-manager:v0.0.1

echo -e "Start ${LGREEN} $APP_NAME ${NC}"

DATABASE_URL=$(curl -s ifconfig.me)

echo ${DATABASE_URL}
while true; do
    read -p "DB INIT?(none/create) : " DB_INIT_YN
    if [[ "$DB_INIT_YN" == "none" ]]; then
        username: $DB_ID=workflow
        password: $DB_PW=tjxjfkxh!23
        SQL_DATA_INIT="never"
        break
    elif [[ "$DB_INIT_YN" == "create" ]]; then
        read -p "Enter The DataBase ID : " DB_ID
        read -p "Enter The DataBase PW : " DB_PW
        SQL_DATA_INIT="always"
        break

    else
        echo "Please enter none or create."
    fi
done



sudo docker run -itd \
        -p 18083:18083 \
        -e DB_INIT_YN=$DB_INIT_YN \
        -e DB_ID=$DB_ID \
        -e DB_PW=$DB_PW \
        -e SQL_DATA_INIT=$SQL_DATA_INIT \
        -v DB_VOLUME_PATH=$DB_VOLUME_PATH \
        --name mc-workflow-manager \
$APP_IMAGE

echo "======================================================================================"
echo "WORKFLOW MANAGER RUN FINISH"
echo "======================================================================================"