module UserService

  def current_user
    if Shared::Web::KeycloakClient.instance.user_signed_in?
      user_info = Shared::Web::KeycloakClient.instance.user_info
      User.find_or_create(user_info)
    end
  end
end
