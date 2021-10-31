FROM ubuntu:latest
ARG DEBIAN_FRONTEND=noninteractive
RUN apt update && apt install default-jdk maven -y
VOLUME [ "/source" ]
CMD [ "mvn", "-q", "-f", "/source", "package"]