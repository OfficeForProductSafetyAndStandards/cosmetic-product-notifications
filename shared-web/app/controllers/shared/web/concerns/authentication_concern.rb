module Shared
  module Web
    module Concerns
      module AuthenticationConcern
        extend ActiveSupport::Concern

        include Shared::Web::LoginHelper

        def initialize
          Keycloak.proc_cookie_token = lambda do
            cookies.permanent[cookie_name]
          end

          super
        end

        def authenticate_user!
          unless user_signed_in? || try_refresh_token
            redirect_to helpers.keycloak_login_url(request.original_fullpath)
          end
        end

        def user_signed_in?
          Shared::Web::KeycloakClient.instance.user_signed_in?
        end

        def cookie_name
          :"keycloak_token_#{ENV['KEYCLOAK_CLIENT_ID']}"
        end

      private

        def try_refresh_token
          begin
            cookies.permanent[cookie_name] = { value: Shared::Web::KeycloakClient.instance.refresh_token, httponly: true }
          rescue StandardError => error
            if error.is_a? Keycloak::KeycloakException
              raise
            else
              false
            end
          end
        end
      end
    end
  end
end
