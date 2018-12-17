module Keycloak
  module Client
    def self.get_installation
      @realm = "opss"
      @auth_server_url = ENV["KEYCLOAK_AUTH_URL"]
      @client_id = ENV["KEYCLOAK_CLIENT_ID"]
      @secret = ENV["KEYCLOAK_CLIENT_SECRET"]
      openid_configuration
    end
  end
end

module Shared
  module Web

    class KeycloakClient
      include Singleton

      def initialize
        @client = Keycloak::Client
        super
      end

      def all_users
        response = Rails.cache.fetch(:keycloak_users, expires_in: 5.minutes) do
          Keycloak::Internal.get_users
        end

        JSON.parse(response).map do |user|
          { id: user["id"], email: user["email"], first_name: user["firstName"], last_name: user["lastName"] }
        end
      end

      def login_url(redirect_uri)
        @client.url_login_redirect(redirect_uri)
      end

      def user_account_url
        @client.url_user_account
      end

      def exchange_code_for_token(code, redirect_uri)
        @client.get_token_by_code(code, redirect_uri)
      end

      def refresh_token
        @client.get_token_by_refresh_token
      end

      def logout
        @client.logout
      end

      def user_signed_in?
        @client.user_signed_in?
      end

      def user_info
        response = @client.get_userinfo
        user = JSON.parse(response)
        { id: user["sub"], email: user["email"], first_name: user["given_name"], last_name: user["family_name"] }
      end

      def has_role?(role)
        @client.has_role? role
      end
    end

  end
end
