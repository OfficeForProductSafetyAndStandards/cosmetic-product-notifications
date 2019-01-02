package uk.gov.beis.mspsds.keycloak.providers;

import org.keycloak.models.KeycloakSession;
import org.keycloak.services.resource.RealmResourceProvider;

public class ExtendedUsersResourceProvider implements RealmResourceProvider {

    private final KeycloakSession session;

    ExtendedUsersResourceProvider(KeycloakSession session) {
        this.session = session;
    }

    @Override
    public Object getResource() {
        return new ExtendedUsersResource(session);
    }

    @Override
    public void close() {
    }
}
