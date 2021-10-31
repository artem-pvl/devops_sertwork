FROM ubuntu:latest
ARG DEBIAN_FRONTEND=noninteractive
ENV CATALINA_BASE /var/lib/tomcat9
ENV PATH $CATALINA_BASE/bin:$PATH
ENV CATALINA_HOME /usr/share/tomcat9
ENV PATH $CATALINA_HOME/bin:$PATH
RUN mkdir -p "$CATALINA_HOME"
RUN apt update && apt install tomcat9 -y
ADD /war/ /var/lib/tomcat9/webapps/
EXPOSE 8080
CMD ["catalina.sh", "run"]