FROM docker.io/library/openjdk:17-jdk-slim
ENV TZ=Asia/Seoul
COPY build/libs/workflow_manager-0.2.1.jar /workflow_manager-0.2.1.jar
ENTRYPOINT ["java", "-jar", "/workflow_manager-0.2.1.jar"]
