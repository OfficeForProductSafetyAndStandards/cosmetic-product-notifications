module LoginHelper
  def keycloak_login_url(request_path=nil)
    KeycloakClient.instance.login_url(get_session_url_with_redirect(request_path))
  end

  def login_page?
    Keycloak.keycloak_controller == controller_name
  end

  def get_session_url_with_redirect(request_path=nil)
    if signin_session_url.exclude? "?"
      param = request_path.blank? ? "" : "?request_path=#{request_path}"
    else
      param = request_path.blank? ? "" : "&request_path=#{request_path}"
    end
    signin_session_url + param
  end
end
