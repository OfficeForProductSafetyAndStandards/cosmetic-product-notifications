FROM maven as notify-builder

WORKDIR /tmp

# Copy the GOV.UK Notify email service provider code
COPY ./providers ./keycloak/providers

COPY ./build-notify.sh ./build-notify.sh
RUN chmod +x ./build-notify.sh
RUN ./build-notify.sh


FROM node:8 as theme-builder

WORKDIR /tmp

# Build GOV.UK Keycloak theme
COPY ./govuk-theme ./keycloak/govuk-theme

COPY ./build-theme.sh ./build-theme.sh
RUN chmod +x ./build-theme.sh
RUN ./build-theme.sh


FROM ubuntu:18.04 as keycloak-builder

WORKDIR /tmp

# Package Keycloak
COPY ./configuration ./keycloak/configuration
COPY --from=notify-builder /tmp/keycloak/package/providers /tmp/keycloak/package/providers
COPY --from=theme-builder /tmp/keycloak/package/themes /tmp/keycloak/package/themes

COPY ./package.sh ./package.sh
RUN chmod +x ./package.sh
RUN ./package.sh

# Disable SSL Mode
RUN sed -i "s/sslmode=require//" ./keycloak/package/standalone/configuration/standalone.xml
RUN sed -i "s/sslmode=require//" ./keycloak/package/standalone/configuration/standalone-ha.xml


FROM jboss/base-jdk:8

ENV LAUNCH_JBOSS_IN_BACKGROUND 1
ENV JBOSS_HOME /opt/jboss/keycloak

USER root

COPY --from=keycloak-builder /tmp/keycloak/package /opt/jboss/keycloak



# Set permissions
RUN chown -R jboss:0 /opt/jboss/keycloak
RUN chmod -R g+rw /opt/jboss/keycloak

USER 1000

EXPOSE 8080

# Launch the standalone server and import realms and users (unless they already exist)
CMD ["/opt/jboss/keycloak/bin/standalone.sh", \
 "-Dkeycloak.migration.action=import", \
 "-Dkeycloak.migration.provider=singleFile", \
 "-Dkeycloak.migration.strategy=IGNORE_EXISTING", \
 "-Dkeycloak.migration.file=/opt/jboss/keycloak/initial-setup.json", \
 "-b", "0.0.0.0"]
