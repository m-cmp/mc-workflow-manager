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
- 18083, 18084 (MC_WORKFLOW)
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
  export PROJECT_ROOT=$HOME/mcmp/git/mc-workflow-manager
  cd $PROJECT_ROOT/script
  sudo chmod +x *.sh
  . $PROJECT_ROOT/script/init-install.sh
  ```

- 환경 변수 설정
  ```bash
  cd $PROJECT_ROOT/script
  . $PROJECT_ROOT/script/set_env.sh
  source $HOME/.bashrc
  ```

### (4) 빌드 및 실행

- Shell Script 실행
  ```bash
  #Run Mariadb
  . $PROJECT_ROOT/script/run-mariadb.sh
  
  #Run Jenkins
  . $PROJECT_ROOT/script/run-jenkins.sh
  
  #Build Springboot Project
  . $PROJECT_ROOT/script/build-mc-workflow.sh
  
  #Run Springboot Project
  . $PROJECT_ROOT/script/run-mc-workflow.sh
  ```

- Swagger 접속
  - http://Public_IP주소:18083/swagger-ui/index.html

- Jenkins 접속
  - http://Public_IP주소:9800


- WorkFlow 기능 - v 0.2.0
  - ToolChain 등록 (*Jenkins / *Tumblebug)
  - Workflow Stage 등록
  - Workflow 등록
  - Workflow 실행

---

---



RUN ENV (임시 서버 연결 2024/06/30까지 가능, 이후 업데이트)
- ${DB_DRIVER} : 기본값 org.mariadb.jdbc.Driver
- ${DB_URL} : 기본값 localhost:3306/m-cmp
- ${DB_ID}
- ${DB_PW}

---

---


## How to Contribute
- Issues/Discussions/Ideas: Utilize issue of mc-workflow-manager
