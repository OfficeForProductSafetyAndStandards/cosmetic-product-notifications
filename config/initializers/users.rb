Rails.application.config.to_prepare do
  begin
    User.data = KeycloakClient.instance.all_users
  rescue RuntimeError => error
    Logger.new(STDOUT).error "Failed to fetch users from Keycloak: #{error.message}"
  end
end
