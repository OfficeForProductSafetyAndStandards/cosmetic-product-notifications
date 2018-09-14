package uk.gov.beis.mspsds.keycloak.providers;

import org.keycloak.email.EmailException;
import org.keycloak.email.EmailSenderProvider;
import org.keycloak.email.EmailTemplateProvider;
import org.keycloak.events.Event;
import org.keycloak.models.KeycloakSession;
import org.keycloak.models.RealmModel;
import org.keycloak.models.UserModel;
import org.keycloak.sessions.AuthenticationSessionModel;

import java.util.Collections;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class NotifyEmailTemplateProvider implements EmailTemplateProvider {

    static String verifyEmailTemplateKey = "verifyEmailTemplateId";
    static String passwordResetTemplateKey = "passwordResetTemplateId";
    static String systemTestTemplateKey = "systemTestTemplateId";

    private final KeycloakSession session;
    private final Map<String, String> templateIds;

    private UserModel user;

    NotifyEmailTemplateProvider(KeycloakSession session, Map<String, String> templateIds) {
        this.session = session;
        this.templateIds = templateIds;
    }

    @Override
    public EmailTemplateProvider setAuthenticationSession(AuthenticationSessionModel authenticationSession) {
        return this;
    }

    @Override
    public EmailTemplateProvider setRealm(RealmModel realm) {
        return this;
    }

    @Override
    public EmailTemplateProvider setUser(UserModel user) {
        this.user = user;
        return this;
    }

    @Override
    public EmailTemplateProvider setAttribute(String name, Object value) {
        return this;
    }

    @Override
    public void sendVerifyEmail(String link, long expirationInMinutes) throws EmailException {
        Map<String, String> config = new HashMap<>();
        config.put("templateId", templateIds.get(verifyEmailTemplateKey));
        config.put("reference", "Verify email");
        config.put("name", getUserName());
        config.put("invitation_url", link);
        config.put("expiry_in_minutes", String.valueOf(expirationInMinutes));

        send(config);
    }

    @Override
    public void sendPasswordReset(String link, long expirationInMinutes) throws EmailException {
        Map<String, String> config = new HashMap<>();
        config.put("templateId", templateIds.get(passwordResetTemplateKey));
        config.put("reference", "Password reset");
        config.put("name", getUserName());
        config.put("reset_url", link);
        config.put("expiry_in_minutes", String.valueOf(expirationInMinutes));

        send(config);
    }

    @Override
    public void sendSmtpTestEmail(Map<String, String> config, UserModel user) throws EmailException {
        config.put("templateId", templateIds.get(systemTestTemplateKey));
        config.put("reference", "Smoke test");
        config.put("name", getUserName());

        send(config);
    }

    @Override
    public void sendConfirmIdentityBrokerLink(String link, long expirationInMinutes) throws EmailException {
        throw new EmailException("No template configured for verifying account during identity brokering", new UnsupportedOperationException());
    }

    @Override
    public void sendExecuteActions(String link, long expirationInMinutes) throws EmailException {
        throw new EmailException("No template configured for required account actions", new UnsupportedOperationException());
    }

    @Override
    public void sendEvent(Event event) throws EmailException {
        throw new EmailException("No template configured for login event notifications", new UnsupportedOperationException());
    }

    @Override
    public void send(String subjectFormatKey, String bodyTemplate, Map<String, Object> bodyAttributes) throws EmailException {
        send(subjectFormatKey, Collections.emptyList(), bodyTemplate, bodyAttributes);
    }

    @Override
    public void send(String subjectFormatKey, List<Object> subjectAttributes, String bodyTemplate, Map<String, Object> bodyAttributes) throws EmailException {
        throw new EmailException("No template configured for arbitrarily formatted emails", new UnsupportedOperationException());
        // TODO: Consider calling the built-in FreeMarkerEmailTemplateProvider to send other email templates
    }

    private String getUserName() {
        return user.getFirstName() != null ? user.getFirstName() : user.getEmail();
    }

    private void send(Map<String, String> config) throws EmailException {
        EmailSenderProvider emailSender = session.getProvider(EmailSenderProvider.class);
        emailSender.send(config, user, null, null, null);
    }

    @Override
    public void close() {
    }
}
