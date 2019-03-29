package uk.gov.beis.opss.keycloak.providers;

import org.keycloak.Config;
import org.keycloak.email.EmailTemplateProvider;
import org.keycloak.email.EmailTemplateProviderFactory;
import org.keycloak.models.KeycloakSession;
import org.keycloak.models.KeycloakSessionFactory;

import java.util.HashMap;
import java.util.Map;

import static uk.gov.beis.opss.keycloak.providers.NotifyEmailTemplateProvider.*;

public class NotifyEmailTemplateProviderFactory implements EmailTemplateProviderFactory {

    private Map<String, String> templateIds;

    @Override
    public EmailTemplateProvider create(KeycloakSession session) {
        return new NotifyEmailTemplateProvider(session, templateIds);
    }

    @Override
    public void init(Config.Scope config) {
        templateIds = new HashMap<>();
        templateIds.put(verifyEmailTemplateKey, config.get(verifyEmailTemplateKey));
        templateIds.put(welcomeEmailTemplateKey, config.get(welcomeEmailTemplateKey));
        templateIds.put(passwordResetTemplateKey, config.get(passwordResetTemplateKey));
        templateIds.put(systemTestTemplateKey, config.get(systemTestTemplateKey));
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
