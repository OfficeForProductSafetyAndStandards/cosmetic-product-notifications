class KeycloakCheck < OkComputer::Check
  def check
    begin
      users = Keycloak::Internal.get_users
      mark_message "Successfully fetched #{JSON.parse(users).length} users"
    rescue StandardError => e
      mark_failure
      mark_message "Failed to fetch users from Keycloak: #{e.message}"
    end
  end
end
