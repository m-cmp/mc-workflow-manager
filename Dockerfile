FROM docker.io/library/openjdk:17-jdk-slim
ENV TZ=Asia/Seoul
COPY ./build/libs/mc-workflow-manager-0.2.1.jar /mc-workflow-manager-0.2.1.jar
ENTRYPOINT ["java", "-jar", "/mc-workflow-manager-0.2.1.jar"]

FROM docker.io/library/openjdk:17-jdk-slim

ENV TZ=Asia/Seoul

# 애플리케이션 복사
COPY ./build/libs/mc-workflow-manager-0.2.1.jar /mc-workflow-manager-0.2.1.jar

# entrypoint 스크립트 복사 및 실행 권한 부여
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# ENTRYPOINT를 스크립트로 설정
ENTRYPOINT ["/entrypoint.sh"]
