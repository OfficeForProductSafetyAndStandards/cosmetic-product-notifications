module Shared
  module Web
    module LoginHelper
      def keycloak_login_url(request_path = nil)
        Shared::Web::KeycloakClient.instance.login_url(get_session_url_with_redirect(request_path))
      end

      def keycloak_registration_url(request_path = nil)
        Shared::Web::KeycloakClient.instance.registration_url(get_session_url_with_redirect(request_path))
      end

      def login_page?
        Keycloak.keycloak_controller == controller_name
      end

      def get_session_url_with_redirect(request_path)
        uri = URI.parse(shared_engine.signin_session_url)
        uri.query = [uri.query, "request_path=#{request_path}"].compact.join('&')
        uri.to_s
      end

      def is_relative(url)
        url =~ /^\/[^\/\\]/
      end
    end
  end
end
