FROM docker.io/library/eclipse-temurin:17-jdk
ENV TZ=Asia/Seoul
COPY build/libs/mc-workflow-manager-0.2.1.jar /mc-workflow-manager-0.2.1.jar
ENTRYPOINT ["java", "-jar", "/mc-workflow-manager-0.2.1.jar"]
