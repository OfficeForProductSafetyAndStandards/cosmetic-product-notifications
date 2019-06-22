module Shared
  module Web
    module LoginHelper
      def keycloak_login_url(request_path = nil)
        Shared::Web::KeycloakClient.instance.login_url(session_url_with_redirect(request_path))
      end

      def keycloak_registration_url(request_path = nil)
        Shared::Web::KeycloakClient.instance.registration_url(session_url_with_redirect(request_path))
      end

      def session_url_with_redirect(request_path)
        uri = URI.parse(session_url)
        uri.query = [uri.query, "request_path=#{request_path}"].compact.join('&')
        uri.to_s
      end

      def session_url
        shared_engine.signin_session_url(host: request.host)
      end
    end
  end
end
