package uk.gov.beis.opss.keycloak.providers;

import org.keycloak.Config;
import org.keycloak.email.EmailSenderProvider;
import org.keycloak.email.EmailSenderProviderFactory;
import org.keycloak.models.KeycloakSession;
import org.keycloak.models.KeycloakSessionFactory;

public class NotifyEmailSenderProviderFactory implements EmailSenderProviderFactory {

    private String apiKey;

    @Override
    public EmailSenderProvider create(KeycloakSession session) {
        return new NotifyEmailSenderProvider(apiKey);
    }

    @Override
    public void init(Config.Scope config) {
        apiKey = config.get("notifyApiKey");
    }

    @Override
    public void postInit(KeycloakSessionFactory factory) {
    }

    @Override
    public void close() {
    }

    @Override
    public String getId() {
        return "notify-email";
    }
}
