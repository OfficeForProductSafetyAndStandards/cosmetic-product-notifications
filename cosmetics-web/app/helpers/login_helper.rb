module LoginHelper
  def keycloak_login_url
    Shared::Web::KeycloakClient.instance.login_url(signin_session_url)
  end

  def login_page?
    Keycloak.keycloak_controller == controller_name
  end
end
