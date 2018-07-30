Rails.application.config.to_prepare do
  begin
    users = JSON.parse(Keycloak::Internal.get_users)
    User.data = users.map do |user|
      {id: user["id"], email: user["email"], first_name: user["firstName"], last_name: user["lastName"]}
    end
  rescue => error
    puts "Failed to fetch users from Keycloak: #{error.message}"
  end
end
