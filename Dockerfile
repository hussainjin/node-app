
FROM tomcat:8-jre8
RUN rm -rf /usr/local/tomcat/webapps/*
COPY target/vprofile-v1.war /usr/local/tomcat/webapps/ROOT.war
EXPOSE 8090
CMD ["catalina.sh","run"]
