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

Rails.application.config.after_initialize do
  begin
    Shared::Web::KeycloakClient.instance.all_organisations unless Rails.env.test? || Sidekiq.server?
  rescue StandardError => e
    # Can be deleted after the following is merged: https://github.com/imagov/keycloak/pull/11
    # The gem we are using is importing client_id and secret too late in default_call method, causing first request
    # to fail, and all following ones to work.
    Rails.logger.error "Failed request to Keycloak: #{e.message}"
  end

  # Load organisations and users on app startup
  Organisation.load unless Rails.env.test? || Sidekiq.server?
  User.load unless Rails.env.test? || Sidekiq.server?
end
