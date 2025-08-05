FROM docker.io/library/openjdk:17-jdk-slim
ENV TZ=Asia/Seoul
RUN apt-get update && \
    apt-get install -y --no-install-recommends curl && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*
COPY ./build/libs/mc-workflow-manager-0.2.1.jar /mc-workflow-manager-0.2.1.jar
ENTRYPOINT ["java", "-jar", "/mc-workflow-manager-0.2.1.jar"]