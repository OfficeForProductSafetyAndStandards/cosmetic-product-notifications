class KeycloakCheck < OkComputer::Check
  def check
    begin
      users = Keycloak::Internal.get_users
      mark_message "Successfully fetched #{JSON.parse(users).length} users"
    rescue StandardError => error
      mark_failure
      mark_message "Failed to fetch users from Keycloak: #{error.message}"
    end
  end
end
