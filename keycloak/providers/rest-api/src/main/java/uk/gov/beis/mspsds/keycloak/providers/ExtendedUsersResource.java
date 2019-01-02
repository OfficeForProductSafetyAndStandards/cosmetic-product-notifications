package uk.gov.beis.mspsds.keycloak.providers;

import org.jboss.resteasy.annotations.cache.NoCache;
import org.keycloak.models.Constants;
import org.keycloak.models.GroupModel;
import org.keycloak.models.KeycloakSession;
import org.keycloak.models.RealmModel;
import org.keycloak.models.UserModel;
import org.keycloak.models.utils.ModelToRepresentation;
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
import java.util.Collections;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

public class ExtendedUsersResource {
    private static final String SEARCH_ID_PARAMETER = "id:";

    private final KeycloakSession session;
    private final RealmModel realm;
    private final AuthResult auth;

    ExtendedUsersResource(KeycloakSession session) {
        this.session = session;
        this.realm = session.getContext().getRealm();
        this.auth = new AppAuthManager().authenticateBearerToken(session, realm);
    }

    /**
     * Get users
     *
     * Returns a list of users, filtered according to query parameters
     *
     * @param search A String contained in username, first or last name, or email
     * @param last
     * @param first
     * @param email
     * @param username
     * @param firstResult Pagination offset
     * @param maxResults Maximum results size (defaults to 100)
     * @return List of UserRepresentation models, including group membership details
     */
    @GET
    @Path("users")
    @NoCache
    @Produces(MediaType.APPLICATION_JSON)
    public List<UserRepresentation> getUsers(@QueryParam("search") String search,
                                             @QueryParam("lastName") String last,
                                             @QueryParam("firstName") String first,
                                             @QueryParam("email") String email,
                                             @QueryParam("username") String username,
                                             @QueryParam("first") Integer firstResult,
                                             @QueryParam("max") Integer maxResults) {

        AdminPermissionEvaluator auth = getAdminPermissionEvaluator();
        auth.users().requireQuery();

        firstResult = firstResult != null ? firstResult : -1;
        maxResults = maxResults != null ? maxResults : Constants.DEFAULT_MAX_RESULTS;

        List<UserRepresentation> results = new ArrayList<>();
        List<UserModel> userModels = Collections.emptyList();
        if (search != null) {
            if (search.startsWith(SEARCH_ID_PARAMETER)) {
                UserModel userModel = session.users().getUserById(search.substring(SEARCH_ID_PARAMETER.length()).trim(), realm);
                if (userModel != null) {
                    userModels = Collections.singletonList(userModel);
                }
            } else {
                userModels = session.users().searchForUser(search.trim(), realm, firstResult, maxResults);
            }
        } else if (last != null || first != null || email != null || username != null) {
            Map<String, String> attributes = new HashMap<>();
            if (last != null) {
                attributes.put(UserModel.LAST_NAME, last);
            }
            if (first != null) {
                attributes.put(UserModel.FIRST_NAME, first);
            }
            if (email != null) {
                attributes.put(UserModel.EMAIL, email);
            }
            if (username != null) {
                attributes.put(UserModel.USERNAME, username);
            }
            userModels = session.users().searchForUser(attributes, realm, firstResult, maxResults);
        } else {
            userModels = session.users().getUsers(realm, firstResult, maxResults, false);
        }

        boolean canViewGlobal = auth.users().canView();
        for (UserModel user : userModels) {
            if (!canViewGlobal && !auth.users().canView(user)) continue;
            UserRepresentation userRep = ModelToRepresentation.toRepresentation(session, realm, user);
            userRep.setGroups(user.getGroups().stream().map(GroupModel::getId).collect(Collectors.toList()));
            userRep.setAccess(auth.users().getAccess(user));
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
