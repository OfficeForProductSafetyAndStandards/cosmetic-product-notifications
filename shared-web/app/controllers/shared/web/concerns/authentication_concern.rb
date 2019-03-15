module Shared
  module Web
    module Concerns
      module AuthenticationConcern
        extend ActiveSupport::Concern

        include Pundit

        include Shared::Web::LoginHelper

        def initialize
          Keycloak.proc_cookie_token = lambda do
            cookies.permanent[cookie_name]
          end

          super
        end

        def authenticate_user!
          return if no_need_to_authenticate

          redirect_to helpers.keycloak_login_url(request.original_fullpath) unless user_signed_in? || try_refresh_token
        end

        def user_signed_in?
          @user_signed_in ||= Shared::Web::KeycloakClient.instance.user_signed_in?
        end

        def set_current_user
          return unless user_signed_in?

          user_info = Shared::Web::KeycloakClient.instance.user_info
          User.current = ::User.find_or_create(user_info)
        end

        def cookie_name
          :"keycloak_token_#{ENV['KEYCLOAK_CLIENT_ID']}"
        end

        def pundit_user
          User.current
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

        def no_need_to_authenticate
          # Can be overridden in projects
          false
        end
      end
    end
  end
end
