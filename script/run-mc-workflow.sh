#!/bin/bash

echo "======================================================================================"
echo "WORKFLOW MANAGER RUN START"
echo "======================================================================================"

# Current project path
PROJECT_PATH=${PROJECT_ROOT}
# Create DB volume
mkdir ${PROJECT_PATH}/DB
DB_VOLUME_PATH=${PROJECT_PATH}/DB

# Application name
APP_NAME=mc-workflow-manager
# Application image name
APP_IMAGE=mc-workflow-manager:v0.2.1

echo -e "Start ${LGREEN} $APP_NAME ${NC}"

DATABASE_URL=$(curl -s ifconfig.me)
DB_ID=""
DB_PW=""

echo ${DATABASE_URL}
while true; do
    read -p "DB INIT?(none/create) : " DB_INIT_YN
    if [[ "$DB_INIT_YN" == "none" ]]; then
        DB_ID="workflow"
        DB_PW="workflow!23"
        echo username: $DB_ID
        echo password: $DB_PW
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
        -v $DB_VOLUME_PATH:/document \
        --name mc-workflow-manager \
$APP_IMAGE

echo "======================================================================================"
echo "WORKFLOW MANAGER RUN FINISH"
echo "======================================================================================"
