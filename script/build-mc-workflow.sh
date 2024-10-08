#!/bin/bash

echo "======================================================================================"
echo "WORKFLOW MANAGER BUILE START"
echo "======================================================================================"

PROJECT_PATH=${PROJECT_ROOT}

sudo chmod +x ${PROJECT_PATH}/gradlew

# mc-workflow build
cd ${PROJECT_PATH}
sudo ./gradlew clean build -x test
echo "build mc-workflow-manager"

sudo chmod +x ${PROJECT_PATH}/build/libs/mc-workflow-manager-0.2.1.jar

echo "docker build"
sudo docker build -f "${PROJECT_PATH}/script/Dockerfile" -t mc-workflow-manager:v0.2.1 .
echo "======================================================================================"
echo "WORKFLOW MANAGER BUILE FINISH"
echo "======================================================================================"