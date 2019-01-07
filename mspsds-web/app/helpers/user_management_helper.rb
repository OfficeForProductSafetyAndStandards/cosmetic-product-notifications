module UserManagementHelper
  def user_account_url
    KeycloakClient.instance.user_account_url
  end

  def user_group_ids
    [current_user.id]
  end
end
