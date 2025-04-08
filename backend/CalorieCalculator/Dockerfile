FROM --platform=linux/amd64 quay.io/wildfly/wildfly:latest

WORKDIR /opt/jboss/wildfly

COPY target/CalorieCalculator-1.0-SNAPSHOT.war /opt/jboss/wildfly/standalone/deployments/ROOT.war

EXPOSE 8080

CMD ["/opt/jboss/wildfly/bin/standalone.sh", "-b", "0.0.0.0"]