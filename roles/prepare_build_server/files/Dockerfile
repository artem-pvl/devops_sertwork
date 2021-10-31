FROM maven:latest
USER root
ARG DEBIAN_FRONTEND=noninteractive
RUN apt update
RUN apt install -y docker.io
RUN apt clean
