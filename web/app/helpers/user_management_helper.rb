module UserManagementHelper
  def url_user_account
    KeycloakClient.instance.url_user_account
  end
end
