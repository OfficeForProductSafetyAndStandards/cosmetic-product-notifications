module LoginHelper
  def keycloak_login_url(request_path = nil)
    ::KeycloakClient.instance.login_url(session_url_with_redirect(request_path))
  end

  def keycloak_registration_url(request_path = nil)
    ::KeycloakClient.instance.registration_url(session_url_with_redirect(request_path))
  end

  def session_url_with_redirect(request_path)
    uri = URI.parse(session_url)
    uri.query = [uri.query, "request_path=#{request_path}"].compact.join('&')
    uri.to_s
  end

  def session_url
    signin_session_url(host: request.host)
  end
end
