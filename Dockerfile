FROM maven:3.6.3-jdk-11-slim AS build

RUN mkdir -p /workspace

WORKDIR /workspace

COPY application/pom.xml /workspace

COPY application/src /workspace/src

RUN pwd && ls -l

COPY --from=build /workspace/target/*.jar app.jar

EXPOSE 8081

ENTRYPOINT ["java","-jar","app.jar"]