#!/bin/bash

sudo chmod +x ${PROJECT_ROOT}/*/gradlew

# mc-workflow build
cd ${PROJECT_ROOT}
gradle wrapper
./gradlew clean build -x test
echo "build mc-workflow-manager"


echo "docker build"
docker build -t mc-workflow-manager:v0.0.1 . 