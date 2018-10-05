FROM maven as notify-build

WORKDIR /tmp/keycloak

RUN mkdir -p ./artifacts
RUN mkdir -p ./package

# Download and unpack Keycloak
RUN curl -Lo ./artifacts/keycloak.tar.gz https://downloads.jboss.org/keycloak/4.3.0.Final/keycloak-4.3.0.Final.tar.gz
RUN tar -xzf ./artifacts/keycloak.tar.gz --directory ./package --strip 1

# Download and add PostgreSQL JDBC driver
RUN curl -Lo ./artifacts/postgresql-42.2.5.jar https://jdbc.postgresql.org/download/postgresql-42.2.5.jar
RUN mkdir -p ./package/modules/system/layers/keycloak/org/postgresql/main
RUN cp ./artifacts/postgresql-42.2.5.jar ./package/modules/system/layers/keycloak/org/postgresql/main

COPY ./providers ./providers
RUN mkdir -p ./package/providers

# Build and copy the GOV.UK Notify email service provider
RUN mvn -q --settings ./providers/email/settings.xml --file ./providers/email/pom.xml package
RUN cp ./providers/email/target/notify-email-provider-jar-with-dependencies.jar ./package/providers/notify-email-provider-jar-with-dependencies.jar

# Build and copy the GOV.UK Notify SMS authenticator provider
RUN mvn -q --file ./providers/sms-authenticator/pom.xml package
RUN cp ./providers/sms-authenticator/target/keycloak-sms-authenticator-sns-*.jar ./package/providers/

# Copy the GOV.UK Notify SMS authenticator page templates
RUN cp ./providers/sms-authenticator/templates/sms-validation.ftl ./package/themes/base/login/
RUN cp ./providers/sms-authenticator/templates/sms-validation-error.ftl ./package/themes/base/login/
RUN cp ./providers/sms-authenticator/templates/sms-validation-mobile-number.ftl ./package/themes/base/login/


FROM node as theme-build

WORKDIR /tmp/govuk-theme

COPY ./govuk-theme .

RUN npm install
RUN npm run build


FROM alpine as keycloak-package

WORKDIR /tmp/keycloak/package

# Copy the Keycloak package from the notify-build docker image
COPY --from=notify-build /tmp/keycloak/package .

# Copy the themes from the theme-build docker image
COPY --from=theme-build /tmp/govuk-theme/govuk ./themes/govuk
COPY --from=theme-build /tmp/govuk-theme/govuk-internal ./themes/govuk-internal
COPY --from=theme-build /tmp/govuk-theme/govuk-social-providers ./themes/govuk-social-providers

# Copy the postgres configuration file
COPY ./configuration/postgresql-module.xml ./modules/system/layers/keycloak/org/postgresql/main/module.xml

# Copy the modified configuration files to enable proxy address forwarding and configuring the PostgreSQL datasource
COPY ./configuration/standalone.xml ./standalone/configuration/standalone.xml
COPY ./configuration/standalone-ha.xml ./standalone/configuration/standalone-ha.xml

# Copy across the initial setup configuration file to be imported on first launch
COPY ./configuration/initial-setup.json ./initial-setup.json


FROM jboss/base-jdk:8

ENV LAUNCH_JBOSS_IN_BACKGROUND 1
ENV JBOSS_HOME /opt/jboss/keycloak

USER root

COPY --from=keycloak-package /tmp/keycloak/package /opt/jboss/keycloak

# Set permissions
RUN chown -R jboss:0 /opt/jboss/keycloak
RUN chmod -R g+rw /opt/jboss/keycloak

# Disable SSL Mode
RUN sed -i "s/sslmode=require//" /opt/jboss/keycloak/standalone/configuration/standalone.xml
RUN sed -i "s/sslmode=require//" /opt/jboss/keycloak/standalone/configuration/standalone-ha.xml

USER 1000

EXPOSE 8080

# Launch the standalone server and import realms and users (unless they already exist)
CMD ["/opt/jboss/keycloak/bin/standalone.sh", \
    "-Dkeycloak.migration.action=import", \
    "-Dkeycloak.migration.provider=singleFile", \
    "-Dkeycloak.migration.strategy=IGNORE_EXISTING", \
    "-Dkeycloak.migration.file=/opt/jboss/keycloak/initial-setup.json", \
    "-b", "0.0.0.0"]
