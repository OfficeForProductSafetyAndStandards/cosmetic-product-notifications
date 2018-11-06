# Set proxy to connect in Keycloak server
Keycloak.proxy = ""
# If true, then all request exceptions will explode in the application (this is the default value)
Keycloak.generate_request_exception = true
# Controller that manages user sessions
Keycloak.keycloak_controller = "sessions"
# Realm name (only used if the installation file is not present)
Keycloak.realm = "mspsds"
# Realm url (only used if the installation file is not present)
Keycloak.auth_server_url = ""
# To load users on app startup
User.all
