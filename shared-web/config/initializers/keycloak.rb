# Set proxy to connect in Keycloak server
Keycloak.proxy = ""
# If true, then all request exceptions will explode in the application (this is the default value)
Keycloak.generate_request_exception = true
# Controller that manages user sessions
Keycloak.keycloak_controller = "sessions"
# Realm name (only used if the installation file is not present)
Keycloak.realm = "opss"
# Realm url (only used if the installation file is not present)
Keycloak.auth_server_url = ""

# Load organisations, teams and users on app startup
Organisation.all unless Rails.env.test? || Sidekiq.server?
Team.all unless Rails.env.test? || Sidekiq.server?
User.all unless Rails.env.test? || Sidekiq.server?
