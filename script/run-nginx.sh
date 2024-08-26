#!/bin/bash

echo "======================================================================================"
echo "NGINX RUN START"
echo "======================================================================================"

cd $HOME

# mcmp 디렉토리 확인 및 생성
if [ ! -d "$HOME/mcmp/oss/nginx" ]; then
  mkdir -p "$HOME/mcmp/oss/nginx"
  chown 1000:1000 "$HOME/mcmp/oss/nginx"
  echo "Created mcmp/nginx directory"
fi

# 색상 코드 설정
LGREEN='\033[1;32m'
NC='\033[0m' # No Color

# 애플리케이션 이름 및 이미지
APP_NAME=nginx
APP_IMAGE=nginx

# Docker 이미지 풀링
echo -e "docker pull ${LGREEN}${APP_NAME}${NC} image."
sudo docker pull $APP_IMAGE

# 기존 nginx 컨테이너가 있으면 종료 및 삭제
if sudo docker ps -a | grep -q nginx; then
  sudo docker stop nginx
  sudo docker rm nginx
fi

# Docker 컨테이너 실행
echo -e "Start ${LGREEN}${APP_NAME}${NC}"

sudo docker run -itd \
  -p 8080:80 \
  -v "$HOME/mcmp/git/mc-workflow-manager/src/main/resources/static/dist:/usr/share/nginx/html/" \
  -v "$HOME/mcmp/git/mc-workflow-manager/workflowFE/nginx/:/etc/nginx/conf.d/" \
  --name nginx \
  -u root \
  $APP_IMAGE

# 컨테이너가 완전히 시작될 때까지 잠시 대기
echo "Waiting for NGINX to start..."
sleep 10

# 연결된 볼륨 및 NGINX 상태 확인
echo "Checking mounted volumes..."
sudo docker inspect nginx | grep '"Source":' | grep -E 'html|conf.d'

echo "======================================================================================"
echo "NGINX RUN FINISH"
echo "======================================================================================"
