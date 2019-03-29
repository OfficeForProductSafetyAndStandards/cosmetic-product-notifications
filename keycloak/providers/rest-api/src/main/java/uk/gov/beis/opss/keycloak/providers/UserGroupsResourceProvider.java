package uk.gov.beis.opss.keycloak.providers;

import org.keycloak.models.KeycloakSession;
import org.keycloak.services.resource.RealmResourceProvider;

public class UserGroupsResourceProvider implements RealmResourceProvider {

    private final KeycloakSession session;

    UserGroupsResourceProvider(KeycloakSession session) {
        this.session = session;
    }

    @Override
    public Object getResource() {
        return new UserGroupsResource(session);
    }

    @Override
    public void close() {
    }
}
