package uk.gov.beis.opss.keycloak.providers;

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
    static String welcomeEmailTemplateKey = "welcomeEmailTemplateId";
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


    /**
     * This method gets triggered by a login attempt from a user with `Verify Email` Required User Action.
     * This is different from the {@link #sendExecuteActions} method which is triggered by the admin.
     */
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
        setUser(user);

        config.put("templateId", templateIds.get(systemTestTemplateKey));
        config.put("reference", "Smoke test");
        config.put("name", getUserName());

        send(config);
    }

    @Override
    public void sendConfirmIdentityBrokerLink(String link, long expirationInMinutes) throws EmailException {
        throw new EmailException("No template configured for verifying account during identity brokering", new UnsupportedOperationException());
    }


    /**
     * This method gets triggered by the Credential Reset admin action in the keycloak console.
     * We are currently using this action as a way to send welcome emails to users.
     */
    @Override
    public void sendExecuteActions(String link, long expirationInMinutes) throws EmailException {
        Map<String, String> config = new HashMap<>();
        config.put("templateId", templateIds.get(welcomeEmailTemplateKey));
        config.put("reference", "Welcome email");
        config.put("name", getUserName());
        config.put("invitation_url", link);
        config.put("expiry_in_minutes", String.valueOf(expirationInMinutes));

        send(config);
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
