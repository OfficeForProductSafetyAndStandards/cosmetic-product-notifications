module UserManagementHelper
  def user_account_url
    Shared::Web::KeycloakClient.instance.user_account_url
  end
end
