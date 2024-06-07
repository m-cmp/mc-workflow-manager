# M-CMP mc-workflow-manager

This repository provides a Workflow Manager.

A sub-system of [M-CMP platform](https://github.com/m-cmp/docs/tree/main) to deploy and manage Multi-Cloud Infrastructures. 

## Overview

M-CMP의 mc-workflow-manager 서브시스템이 제공하는 기능은 다음과 같다.

- 워크플로우 생성 기능
- 워크플로우를 통한 멀티 클라우드 인프라 생성 및 애플리케이션 배포 기능


## 목차

1. [mc-workflow-manager 실행 및 개발 환경]
2. [mc-workflow-manager 실행 방법]
3. [mc-workflow-manager 소스 빌드 및 실행 방법 상세]
4. [mc-workflow-manager 기여 방법]

---

---


## mc-workflow-manager 실행 및 개발 환경

- Linux OS (Ubuntu 22.04 LTS)
- Java (Openjdk 11)
- Gradle (v7.6)
- MariaDB (v10.11.5)
- Jenkins (v2.424)
- docker (v24.0.2)
- git (v2.34.1)

---

---

## mc-workflow-manager 실행 방법

### 소스 코드 기반 설치 및 실행

- 방화벽 설정
- 소스 다운로드 (Git clone)
- 필요 패키지/도구 설치 (Java, Gradle, Git, Docker)
- 빌드 및 실행 (shell script)

---

---

## mc-workflow-manager 소스 빌드 및 실행 방법 상세

### (1) 방화벽 TCP 포트 허용 설정

- 80, 443
- 3306 (MariaDB)
- 9800 (Jenkins)
- 18084 (MC_WORKFLOW)
- 1024 (MC_SPIDER)
- 1323 (CB_TUMBLEBUG)

### (2) 소스 다운로드

- Git 설치
  ```bash
  	sudo apt update
  	sudo apt install -y git
  ```
- mc-workflow-manager 소스 다운로드
  ```bash
  	export BASE_DIR=$HOME/mcmp
  	mkdir -p $BASE_DIR/git
  	cd $BASE_DIR/git
  	git clone https://github.com/m-cmp/mc-workflow-manager.git
  	export PROJECT_ROOT=$(pwd)/mc-workflow-manager
  ```

### (3) 필요 패키지/도구 설치 및 환경 변수 설정

- Java, Gradle, Git, Docker 설치

  ```bash
  	cd $PROJECT_ROOT/scripts
  	sudo chmod +x *.sh
  	. $PROJECT_ROOT/scripts/init-install.sh
  	mkdir -p $BASE_DIR/build

  ```

- 환경 변수 설정
  ```bash
  	cd $PROJECT_ROOT/scripts
  	. $PROJECT_ROOT/scripts/set-env.sh
  	source $HOME/.bashrc
  ```

### (4) 빌드 및 실행

- Shell Script 실행

  ```bash
    #Run Mariadb
  	. $PROJECT_ROOT/scripts/run-mariadb.sh

  	#Run Jenkins
  	. $PROJECT_ROOT/scripts/run-jenkins.sh

  	#Build Springboot Project
  	. $PROJECT_ROOT/scripts/build-mc-workflow.sh

  	#Run Springboot Project
  	. $PROJECT_ROOT/scripts/run-mc-workflow.sh

    
  ```

- Swagger 접속
  - http://Public_IP주소:18084/swagger-ui/index.html

- Jenkins 접속
  - http://Public_IP주소:9800

- WorkFlow 실행
  - Swagger를 통해 workflow pipeline을 생성 후
  - Jenkins의 새로운 Item 생성 클릭 후
  - Item 이름 작성, pipeline 선택 후 저장
  - Workflow로 만든 pipeline을 입력 후 저장
  - 지금 빌드 버튼 클릭

---

---

- 컨테이너 저장소

  - 임시(AWS ECR public) 06/07~06/30
  - public.ecr.aws/m5m6d0w2/m-cmp-workflow-manager

- pull command
  ```bash
  docker pull public.ecr.aws/m5m6d0w2/m-cmp-workflow-manager:latest
  ```


---

---


## How to Contribute

- Issues/Discussions/Ideas: Utilize issue of mc-workflow-manager
