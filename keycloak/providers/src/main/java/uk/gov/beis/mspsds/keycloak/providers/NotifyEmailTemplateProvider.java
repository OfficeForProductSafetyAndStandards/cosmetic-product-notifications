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

    private final KeycloakSession session;

    private final String invitationTemplateId;
    private final String passwordResetTemplateId;

    private UserModel user;

    NotifyEmailTemplateProvider(KeycloakSession session, String invitationTemplateId, String passwordResetTemplateId) {
        this.session = session;
        this.invitationTemplateId = invitationTemplateId;
        this.passwordResetTemplateId = passwordResetTemplateId;
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
        config.put("templateId", invitationTemplateId);
        config.put("reference", "Verify email");
        config.put("name", getUserName());
        config.put("invitation_url", link);
        config.put("expiry_in_minutes", String.valueOf(expirationInMinutes));

        send(config);
    }

    @Override
    public void sendPasswordReset(String link, long expirationInMinutes) throws EmailException {
        Map<String, String> config = new HashMap<>();
        config.put("templateId", passwordResetTemplateId);
        config.put("reference", "Password reset");
        config.put("name", getUserName());
        config.put("reset_url", link);
        config.put("expiry_in_minutes", String.valueOf(expirationInMinutes));

        send(config);
    }

    @Override
    public void sendSmtpTestEmail(Map<String, String> config, UserModel user) throws EmailException {
        config.put("templateId", passwordResetTemplateId);
        config.put("reference", "Keycloak smoke test");
        config.put("name", getUserName());
        config.put("reset_url", "http://www.example.com");
        config.put("expiry_in_minutes", "0");

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
//        // TODO: Call built-in FreeMarkerEmailTemplateProvider to send other email templates
//        FreeMarkerEmailTemplateProvider freeMarkerEmailTemplateProvider = new FreeMarkerEmailTemplateProvider(session, new FreeMarkerUtil());
//        freeMarkerEmailTemplateProvider.send(subjectFormatKey, subjectAttributes, bodyTemplate, bodyAttributes);
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
