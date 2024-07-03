#!/bin/bash

cd $HOME
if [ ! -d mcmp ]; then
  mkdir -p $HOME/mcmp/oss/mariadb
  chown 1000:1000 $HOME/mcmp/oss/mariadb
  echo "Create mariadb dir"
fi

LGREEN='\033[1;32m'
NC='\033[0m' # No Color

APP_NAME=mariadb
APP_IMAGE=mariadb:10.11.5



echo -e "docker pull ${LGREEN} $APP_NAME ${NC} image."
sudo docker pull $APP_IMAGE

echo -e "Start ${LGREEN} $APP_NAME ${NC}"

sudo docker run -d \
        --restart=always \
        --name=$APP_NAME \
        -p 3306:3306 \
	      -e MYSQL_ROOT_PASSWORD=mcmp \
        -e MARIADB_DATABASE=mcmp \
  	    -v /etc/localtime:/etc/localtime \
  	    -v $HOME/mcmp/oss/mariadb:/var/lib/mysql \
$APP_IMAGE

# 컨테이너가 완전히 시작될 때까지 잠시 대기
echo "Waiting for MariaDB to start..."
sleep 10

#RUN DDL
DB_USER="root"
DB_PASSWORD="mcmp"
DB_NAME="mcmp"
SQL_FILE_PATH=$HOME/mcmp/git/mc-workflow-manager/ddl_20240618.sql

# MariaDB 명령어 실행
sudo docker exec -i $APP_NAME mysql -u $DB_USER -p$DB_PASSWORD $DB_NAME < $SQL_FILE_PATH