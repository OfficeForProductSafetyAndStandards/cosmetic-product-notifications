module UserService
  def current_user
    user_info = KeycloakClient.instance.user_info
    User.find_or_create(user_info)
  end
end
