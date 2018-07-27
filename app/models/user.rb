class User
  def initialize
    userinfo = JSON(Keycloak::Client.get_userinfo)
    @user_id = userinfo[:sub]
    @email = userinfo[:email]
  end

  def self.all
    Keycloak::Internal.get_users
  end

  def self.find(email)
    Keycloak::Internal.get_user_info(email)
  end

  def has_role?(role)
    Keycloak::Client.has_role? role
  end
end
