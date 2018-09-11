package uk.gov.beis.mspsds.keycloak.providers;

import org.keycloak.Config;
import org.keycloak.email.EmailTemplateProvider;
import org.keycloak.email.EmailTemplateProviderFactory;
import org.keycloak.models.KeycloakSession;
import org.keycloak.models.KeycloakSessionFactory;

public class NotifyEmailTemplateProviderFactory implements EmailTemplateProviderFactory {

    private String invitationTemplateId;
    private String passwordResetTemplateId;

    @Override
    public EmailTemplateProvider create(KeycloakSession session) {
        return new NotifyEmailTemplateProvider(session, invitationTemplateId, passwordResetTemplateId);
    }

    @Override
    public void init(Config.Scope config) {
        invitationTemplateId = config.get("invitationTemplateId");
        passwordResetTemplateId = config.get("passwordResetTemplateId");
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
