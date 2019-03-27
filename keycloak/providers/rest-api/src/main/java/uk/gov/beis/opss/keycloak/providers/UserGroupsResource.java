package uk.gov.beis.opss.keycloak.providers;

import org.jboss.resteasy.annotations.cache.NoCache;
import org.keycloak.models.Constants;
import org.keycloak.models.GroupModel;
import org.keycloak.models.KeycloakSession;
import org.keycloak.models.RealmModel;
import org.keycloak.models.UserModel;
import org.keycloak.representations.idm.UserRepresentation;
import org.keycloak.services.managers.AppAuthManager;
import org.keycloak.services.managers.AuthenticationManager.AuthResult;
import org.keycloak.services.resources.admin.AdminAuth;
import org.keycloak.services.resources.admin.permissions.AdminPermissionEvaluator;
import org.keycloak.services.resources.admin.permissions.AdminPermissions;

import javax.ws.rs.GET;
import javax.ws.rs.NotAuthorizedException;
import javax.ws.rs.Path;
import javax.ws.rs.Produces;
import javax.ws.rs.QueryParam;
import javax.ws.rs.core.MediaType;
import java.util.ArrayList;
import java.util.List;
import java.util.stream.Collectors;

public class UserGroupsResource {

    private final KeycloakSession session;
    private final RealmModel realm;
    private final AuthResult auth;

    UserGroupsResource(KeycloakSession session) {
        this.session = session;
        this.realm = session.getContext().getRealm();
        this.auth = new AppAuthManager().authenticateBearerToken(session, realm);
    }

    /**
     * Get user groups
     *
     * Returns a list of users with the group IDs they belong to
     *
     * @param firstResult Pagination offset
     * @param maxResults Maximum number of results (defaults to 100)
     * @return List of UserRepresentation models, each containing the user ID and list of associated group IDs
     *
     * Based on the {@link org.keycloak.services.resources.admin.UsersResource#getUsers getUsers} method from the Keycloak Admin REST API.
     */
    @GET
    @Path("user-groups")
    @NoCache
    @Produces(MediaType.APPLICATION_JSON)
    public List<UserRepresentation> getUserGroups(@QueryParam("first") Integer firstResult,
                                                  @QueryParam("max") Integer maxResults) {

        AdminPermissionEvaluator auth = getAdminPermissionEvaluator();
        auth.users().requireQuery();

        firstResult = firstResult != null ? firstResult : -1;
        maxResults = maxResults != null ? maxResults : Constants.DEFAULT_MAX_RESULTS;

        List<UserModel> userModels = session.users().getUsers(realm, firstResult, maxResults, false);
        List<UserRepresentation> results = new ArrayList<>();

        boolean canViewGlobal = auth.users().canView();
        for (UserModel user : userModels) {
            if (!canViewGlobal && !auth.users().canView(user)) continue;
            UserRepresentation userRep = new UserRepresentation();
            userRep.setId(user.getId());
            userRep.setGroups(user.getGroups().stream().map(GroupModel::getId).collect(Collectors.toList()));
            results.add(userRep);
        }
        return results;
    }

    private AdminPermissionEvaluator getAdminPermissionEvaluator() {
        if (auth == null) {
            throw new NotAuthorizedException("Bearer");
        }

        AdminAuth adminAuth = new AdminAuth(realm, auth.getToken(), auth.getUser(), session.getContext().getClient());
        return AdminPermissions.evaluator(session, realm, adminAuth);
    }
}
