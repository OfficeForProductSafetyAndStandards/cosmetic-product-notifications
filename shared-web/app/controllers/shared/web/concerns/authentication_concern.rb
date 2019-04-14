module Shared
  module Web
    module Concerns
      module AuthenticationConcern
        extend ActiveSupport::Concern

        include Pundit

        include Shared::Web::LoginHelper

        def initialize
          Keycloak.proc_cookie_token = -> { nil }
          super
        end

        def authenticate_user!
          redirect_to helpers.keycloak_login_url(request.original_fullpath) unless user_signed_in? || try_refresh_token
        end

        def user_signed_in?
          @user_signed_in ||= Shared::Web::KeycloakClient.instance.user_signed_in?(access_token)
        end

        def set_current_user
          return unless user_signed_in?

          user_info = Shared::Web::KeycloakClient.instance.user_info(access_token)
          User.current = ::User.find_or_create(user_info)
        end

        def cookie_name
          :"keycloak_token_#{ENV['KEYCLOAK_CLIENT_ID']}"
        end

        def pundit_user
          User.current
        end

      private

        def access_token
          keycloak_token["access_token"]
        end

        def refresh_token
          keycloak_token["refresh_token"]
        end

        def keycloak_token
          JSON cookies.permanent[cookie_name]
        end

        def try_refresh_token
          begin
            cookies.permanent[cookie_name] = {
              value: Shared::Web::KeycloakClient.instance.exchange_refresh_token_for_token(refresh_token),
              httponly: true
            }
          rescue StandardError => e
            if e.is_a? Keycloak::KeycloakException
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
