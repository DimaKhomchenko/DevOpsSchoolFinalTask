FROM alpine:latest as builder
RUN apk update && apk add git openjdk11-jre maven
WORKDIR /home/user/build
RUN git clone https://github.com/boxfuse/boxfuse-sample-java-war-hello.git .
RUN mvn package

FROM tomcat:10
WORKDIR /usr/local/tomcat/webapps
COPY --from=builder /home/user/build/target/*.war . 
CMD ["catalina.sh", "run"]