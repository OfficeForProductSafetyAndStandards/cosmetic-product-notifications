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

begin
  Shared::Web::KeycloakClient.instance.all_organisations
rescue RestClient::BadRequest
  # It seems first request to keycloak is rejected with error=invalid_client_credentials
  # If keycloak is actually down, we will see it in logs of following requests
end

Rails.application.config.after_initialize do
  # Load organisations and users on app startup
  Organisation.all unless Rails.env.test? || Sidekiq.server?
  User.all unless Rails.env.test? || Sidekiq.server?
end
