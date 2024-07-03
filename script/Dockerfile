FROM docker.io/library/openjdk:11-jdk-slim
ENV TZ=Asia/Seoul
COPY build/libs/wfManager-0.0.1.jar /wfManager-0.0.1.jar
ENTRYPOINT ["java", "-jar", "/wfManager-0.0.1.jar"]
