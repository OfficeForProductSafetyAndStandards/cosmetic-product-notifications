# GOV.UK Notify Email Provider for Keycloak

This project provides a custom implementation of Keycloak's email sender [Service Provider Interface](https://www.keycloak.org/docs/latest/server_development/index.html#_providers)
that uses the [GOV.UK Notify](https://www.notifications.service.gov.uk) service
to send account verification and password reset emails from Keycloak.

For now, system event emails (e.g. for notifying admins about failed login attempts)
are not supported, but these would be simple to add if needed in the future, by creating
a new email template and implementing the relevant method in `NotifyEmailTemplateProvider`.


## Getting Setup

No additional setup is required beyond the steps listed in [the root README](../../README.md#getting-setup).

You will need to specify a Notify API key in your `.env` file to be able to test email integration
(see the [accounts section](../../README.md#accounts) of the root README for information on how to obtain one).


### IDE Setup

IntelliJ or VS Code are the preferred IDEs.

If using IntelliJ, open the project by importing as a Maven project from the `keycloak/providers/pom.xml` file.

To build and package the project:
* **IntelliJ:** run the "Package" configuration
* **VS Code:**  Right-click `notify-email-provider` under Maven Projects and select "package"


## Deployment

By default, this project is built and deployed automatically as part of the main Keycloak deployment process
[described here](../../README.md#deployment).

### Deploying manually

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
                    <property name="verifyEmailTemplateId" value="VERIFY_EMAIL_TEMPLATE_ID"/>
                    <property name="welcomeEmailTemplateId" value="WELCOME_EMAIL_TEMPLATE_ID"/>
                    <property name="passwordResetTemplateId" value="PASSWORD_RESET_TEMPLATE_ID"/>
                    <property name="systemTestTemplateId" value="SYSTEM_TEST_TEMPLATE_ID"/>
                </properties>
            </provider>
        </spi>
    </subsystem>

Then start (or restart) the server.

Once started, confirm the provider has been successfully registered: open the admin console, select Server Info from
the Admin dropdown menu on the top-right of the page, then click on the Providers tab and search for "emailSender".


### Deploying as a separate module

Alternatively you can deploy the provider as a module by running:

    KEYCLOAK_HOME/bin/jboss-cli.sh --command="module add --name=uk.gov.beis.opss.keycloak.providers.notify-email --resources=target/notify-email-provider.jar --dependencies=org.keycloak.keycloak-core,org.keycloak.keycloak-server-spi,org.keycloak.keycloak-server-spi-private"

Then register the provider by editing `standalone/configuration/standalone.xml` and adding the module to the providers element:

    <providers>
        ...
        <provider>module:uk.gov.beis.opss.keycloak.providers.notify-email</provider>
    </providers>
