# 멀티스테이지 빌드

# 첫 번째 단계에서 app.jar 파일을 레이어로 추출한다.
FROM openjdk:17-jdk as builder
ARG JAR_FILE="build/libs/*.jar"
WORKDIR app
COPY ${JAR_FILE} app.jar
RUN java -Djarmode=layertools -jar app.jar extract

# 두 번째 단계에서 첫 번째 단계에서 빌드한 레이어들만 가져와서 레이어를 작업 디렉토리에 복사한다.
FROM openjdk:17-jdk
WORKDIR app
VOLUME /tmp

COPY --from=builder app/dependencies/ ./
COPY --from=builder app/spring-boot-loader/ ./
COPY --from=builder app/snapshot-dependencies/ ./
COPY --from=builder app/application/ ./
ENV PROFILE local
# springboot 3.2.0 버전 이전에선 아래와 같았으나 개발진이 relocate함
# ENTRYPOINT ["java", "-Dspring.profiles.active=${PROFILE}", "org.springframework.boot.loader.JarLauncher"]
ENTRYPOINT ["java", "-Dspring.profiles.active=${PROFILE}", "org.springframework.boot.loader.launch.JarLauncher"]
