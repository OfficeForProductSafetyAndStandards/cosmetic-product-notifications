module LoginHelper
  def keycloak_login_url(request_url=nil)
    KeycloakClient.instance.login_url(get_session_url_with_redirect(request_url))
  end

  def login_page?
    Keycloak.keycloak_controller == controller_name
  end

  def get_session_url_with_redirect(request_url=nil)
    if signin_session_url.exclude? "?"
      param = request_url.blank? ? "" : "?request_url=#{request_url}"
    else
      param = request_url.blank? ? "" : "&request_url=#{request_url}"
    end
    signin_session_url + param
  end
end
