FROM jboss/base-jdk:8

ENV LAUNCH_JBOSS_IN_BACKGROUND 1
ENV JBOSS_HOME /opt/jboss/keycloak

WORKDIR /tmp

USER root

####################
# Package Keycloak #
####################

COPY . ./keycloak
RUN chmod +x ./keycloak/package.sh
RUN ./keycloak/package.sh
RUN mv ./keycloak/package /opt/jboss/keycloak

####################
# Disable SSL Mode #
####################

RUN sed -i "s/sslmode=require//" /opt/jboss/keycloak/standalone/configuration/standalone.xml
RUN sed -i "s/sslmode=require//" /opt/jboss/keycloak/standalone/configuration/standalone-ha.xml

###################
# Set permissions #
###################

RUN chown -R jboss:0 /opt/jboss/keycloak
RUN chmod -R g+rw /opt/jboss/keycloak

###################
# Copy entrypoint #
###################

COPY ./docker-entrypoint.sh /
RUN chmod +x /docker-entrypoint.sh

USER 1000

EXPOSE 8080

ENTRYPOINT ["/docker-entrypoint.sh"]

CMD ["-b", "0.0.0.0"]
