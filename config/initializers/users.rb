def keycloak_users
  users_data = Rails.cache.fetch("keycloak_users", expires_in: 5.minutes) do
    Keycloak::Internal.get_users
  end
  JSON.parse(users_data)
end

Rails.application.config.to_prepare do
  begin
    User.data = keycloak_users.map do |user|
      { id: user["id"], email: user["email"], first_name: user["firstName"], last_name: user["lastName"] }
    end
  rescue RuntimeError => error
    Logger.new(STDOUT).error "Failed to fetch users from Keycloak: #{error.message}"
  end
end
