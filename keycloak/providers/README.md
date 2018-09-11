# GOV.UK Notify Email Provider for Keycloak


## Getting Setup


## Deployment

To deploy, copy `target/notify-email-provider-jar-with-dependencies.jar` to the `providers` directory in the Keycloak package.

The Notify API key and relevant email template IDs are specified by adding the following to `standalone/configuration/standalone.xml`:

    <subsystem xmlns="urn:jboss:domain:keycloak-server:1.1">
        ...
        <spi name="emailSender">
            <default-provider>notify-email</default-provider>
            <provider name="default" enabled="false"/>
            <provider name="notify-email" enabled="true">
                <properties>
                    <property name="notifyApiKey" value="NOTIFY_API_KEY"/>
                </properties>
            </provider>
        </spi>
        <spi name="emailTemplate">
            <default-provider>notify-email</default-provider>
            <provider name="default" enabled="false"/>
            <provider name="notify-email" enabled="true">
                <properties>
                    <property name="invitationTemplateId" value="INVITATION_TEMPLATE_ID"/>
                    <property name="passwordResetTemplateId" value="PASSWORD_RESET_TEMPLATE_ID"/>
                </properties>
            </provider>
        </spi>
    </subsystem>

Then start (or restart) the server.

Once started, confirm the provider has been successfully registered: open the admin console, select Server Info from
the Admin dropdown menu on the top-right of the page, then click on the Providers tab and search for "emailSender".


### Deploying as a separate module

Alternatively you can deploy the provider as a module by running:

    KEYCLOAK_HOME/bin/jboss-cli.sh --command="module add --name=uk.gov.beis.mspsds.keycloak.providers.notify-email --resources=target/notify-email-provider.jar --dependencies=org.keycloak.keycloak-core,org.keycloak.keycloak-server-spi,org.keycloak.keycloak-server-spi-private"

Then register the provider by editing `standalone/configuration/standalone.xml` and adding the module to the providers element:

    <providers>
        ...
        <provider>module:uk.gov.beis.mspsds.keycloak.providers.notify-email</provider>
    </providers>
