# rubocop:disable Naming/AccessorMethodName (overriding method from external library)
module Keycloak
  module Client
    def self.get_installation
      @realm = "mspsds"
      @auth_server_url = ENV["KEYCLOAK_AUTH_URL"]
      @client_id = ENV["KEYCLOAK_CLIENT_ID"]
      @secret = ENV["KEYCLOAK_CLIENT_SECRET"]
      openid_configuration
    end
  end
end
# rubocop:enable Naming/AccessorMethodName

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

  def send_password_reset_email(user, redirect_uri)
    Keycloak::Internal.forgot_password(user[:email], redirect_uri)
  end

  def token_for_user(user)
    @client.get_token(user[:email], user[:password])
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
