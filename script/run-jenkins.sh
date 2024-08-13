#!/bin/bash

echo "======================================================================================"
echo "JENKINS RUN START"
echo "======================================================================================"
cd $HOME
if [ ! -d mcmp ]; then
  mkdir -p $HOME/mcmp/oss/jenkins
  chown 1000:1000 $HOME/mcmp/oss/jenkins
  echo "Create jenkins dir"
fi

LGREEN='\033[1;32m'
NC='\033[0m' # No Color

APP_NAME=jenkins
APP_IMAGE=jenkins/jenkins:jdk17


echo -e "docker pull ${LGREEN} $APP_NAME ${NC} image."
sudo docker pull $APP_IMAGE

echo -e "Start ${LGREEN} $APP_NAME ${NC}"

HOME=$HOME
sudo docker run -itd \
        -p 9800:8080 \
        -v $HOME/mcmp/oss/jenkins:/var/jenkins_home \
        -v /var/run/docker.sock:/var/run/docker.sock \
        -v $(which docker):/usr/bin/docker \
        --name jenkins \
        -u root \
$APP_IMAGE

# 컨테이너가 완전히 시작될 때까지 잠시 대기
echo "Waiting for Jenkins to start..."
sleep 10

echo "Init Password"
sudo docker exec jenkins cat /var/jenkins_home/secrets/initialAdminPassword

echo "======================================================================================"
echo "JENKINS RUN FINISH"
echo "======================================================================================"