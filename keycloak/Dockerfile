FROM maven as keycloak-build

WORKDIR /tmp/keycloak

RUN mkdir -p ./artifacts
RUN mkdir -p ./package

ENV keycloakVersion 4.8.3

# Download and unpack Keycloak
RUN curl -Lo ./artifacts/keycloak.tar.gz https://downloads.jboss.org/keycloak/$keycloakVersion.Final/keycloak-$keycloakVersion.Final.tar.gz
RUN tar -xzf ./artifacts/keycloak.tar.gz --directory ./package --strip 1

# Download and add PostgreSQL JDBC driver
RUN curl -Lo ./artifacts/postgresql-42.2.5.jar https://jdbc.postgresql.org/download/postgresql-42.2.5.jar
RUN mkdir -p ./package/modules/system/layers/keycloak/org/postgresql/main
RUN cp ./artifacts/postgresql-42.2.5.jar ./package/modules/system/layers/keycloak/org/postgresql/main

# Download and copy the commonly-used password blacklist
RUN curl -Lo ./artifacts/10-million-password-list-top-1000000.txt https://raw.githubusercontent.com/danielmiessler/SecLists/2018.3/Passwords/Common-Credentials/10-million-password-list-top-1000000.txt
RUN mkdir -p ./package/standalone/data/password-blacklists
RUN cp ./artifacts/10-million-password-list-top-1000000.txt ./package/standalone/data/password-blacklists/

# Copy the GOV.UK Notify SMS authenticator page templates
COPY ./providers/sms-authenticator/templates ./templates
RUN cp ./templates/sms-validation.ftl ./package/themes/base/login/
RUN cp ./templates/sms-validation-error.ftl ./package/themes/base/login/
RUN cp ./templates/sms-validation-mobile-number.ftl ./package/themes/base/login/

RUN cat ./templates/messages/messages_en.properties >> ./package/themes/base/login/messages/messages_en.properties


# Build and copy the GOV.UK Notify email service provider
FROM maven as notify-email-build

WORKDIR /tmp/keycloak

COPY ./providers/email ./email
RUN mkdir -p ./providers

RUN mvn -q --file ./email/pom.xml package
RUN cp ./email/target/notify-email-provider-jar-with-dependencies.jar ./providers/


# Build and copy the mobile number registration form action
FROM maven as registration-form-build

WORKDIR /tmp/keycloak

COPY ./providers/registration-form ./registration-form
RUN mkdir -p ./providers

RUN mvn -q --file ./registration-form/pom.xml package
RUN cp ./registration-form/target/mobile-number-form-action-jar-with-dependencies.jar ./providers/


# Build and copy the user groups resource provider
FROM maven as rest-api-build

WORKDIR /tmp/keycloak

COPY ./providers/rest-api ./rest-api
RUN mkdir -p ./providers

RUN mvn -q --file ./rest-api/pom.xml package
RUN cp ./rest-api/target/user-groups-resource-provider-jar-with-dependencies.jar ./providers/


# Build and copy the GOV.UK Notify SMS authenticator provider
FROM maven as sms-authenticator-build

WORKDIR /tmp/keycloak

COPY ./providers/sms-authenticator ./sms-authenticator
RUN mkdir -p ./providers

RUN mvn -q --file ./sms-authenticator/pom.xml package
RUN cp ./sms-authenticator/target/keycloak-sms-authenticator-sns-*.jar ./providers/


# Build and copy the System Out event listener provider
FROM maven as system-out-event-listener-build

WORKDIR /tmp/keycloak

COPY ./providers/system-out-event-listener ./system-out-event-listener
RUN mkdir -p ./providers

RUN mvn -q --file ./system-out-event-listener/pom.xml package
RUN cp ./system-out-event-listener/target/system-out-event-listener-*.jar ./providers/


# Build and copy the GOV.UK theme
FROM node as theme-build

WORKDIR /tmp/govuk-theme

COPY ./govuk-theme .

RUN npm install
RUN npm run build


# Package the built components
FROM alpine as keycloak-package

WORKDIR /tmp/keycloak/package

# Copy the Keycloak package from the keycloak-build docker image
COPY --from=keycloak-build /tmp/keycloak/package .

# Copy the custom providers from the relevant docker images
COPY --from=notify-email-build /tmp/keycloak/providers ./providers/
COPY --from=registration-form-build /tmp/keycloak/providers ./providers/
COPY --from=rest-api-build /tmp/keycloak/providers ./providers/
COPY --from=sms-authenticator-build /tmp/keycloak/providers ./providers/
COPY --from=system-out-event-listener-build /tmp/keycloak/providers ./providers/

# Copy the themes from the theme-build docker image
COPY --from=theme-build /tmp/govuk-theme/govuk ./themes/govuk
COPY --from=theme-build /tmp/govuk-theme/govuk-internal ./themes/govuk-internal
COPY --from=theme-build /tmp/govuk-theme/govuk-social-providers ./themes/govuk-social-providers
COPY --from=theme-build /tmp/govuk-theme/govuk-cosmetics ./themes/govuk-cosmetics
COPY --from=theme-build /tmp/govuk-theme/govuk-psd ./themes/govuk-psd

# Copy the postgres configuration file
COPY ./configuration/postgresql-module.xml ./modules/system/layers/keycloak/org/postgresql/main/module.xml

# Copy the modified configuration files to enable proxy address forwarding and configuring the PostgreSQL datasource
COPY ./configuration/standalone.xml ./standalone/configuration/standalone.xml
COPY ./configuration/standalone-ha.xml ./standalone/configuration/standalone-ha.xml

# Copy across the initial setup configuration file to be imported on first launch
COPY ./configuration/initial-setup.json ./configuration/initial-setup.json


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
    "-Dkeycloak.migration.strategy=OVERWRITE_EXISTING", \
    "-Dkeycloak.migration.file=/opt/jboss/keycloak/configuration/initial-setup.json", \
    "-b", "0.0.0.0"]
