module Shared
  module Web
    module LoginHelper
      def keycloak_login_url
        Shared::Web::KeycloakClient.instance.login_url(shared_engine.signin_session_url)
      end

      def login_page?
        Keycloak.keycloak_controller == controller_name
      end

      def cookie_name
        :"keycloak_token_#{ENV['KEYCLOAK_CLIENT_ID']}"
      end
    end
  end
end
