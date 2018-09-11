package uk.gov.beis.mspsds.keycloak.providers;

import org.keycloak.email.EmailException;
import org.keycloak.email.EmailSenderProvider;
import org.keycloak.models.UserModel;
import uk.gov.service.notify.NotificationClient;
import uk.gov.service.notify.NotificationClientException;

import java.util.Map;

public class NotifyEmailSenderProvider implements EmailSenderProvider {

    private final NotificationClient client;

    NotifyEmailSenderProvider(String apiKey) {
        client = new NotificationClient(apiKey);
    }

    @Override
    public void send(Map<String, String> config, UserModel user, String subject, String textBody, String htmlBody) throws EmailException {
        System.out.println("NOTIFY CLIENT API KEY: " + client.getApiKey());
        System.out.println("EMAIL ADDRESS: " + user.getEmail());
        System.out.println("CONFIGURATION: " + config.toString());

        String emailAddress = user.getEmail();
        String templateId = config.remove("templateId");
        String reference = config.remove("reference");

        try {
            client.sendEmail(templateId, emailAddress, config, reference);
        } catch (NotificationClientException e) {
            System.err.println("Failed to send email request to Notify API: " + e.getLocalizedMessage());
            throw new EmailException("Failed to send email via Notify", e);
        }
    }

    @Override
    public void close() {
    }
}
