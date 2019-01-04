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

  module Internal
    def self.get_groups
      proc = lambda { |token|
        request_uri = Keycloak::Admin.full_url("groups")
        Keycloak.generic_request(token["access_token"], request_uri, nil, nil, "GET")
      }

      default_call(proc)
    end

    def self.get_user_groups
      proc = lambda { |token|
        request_uri = Keycloak::Client.auth_server_url + "/realms/#{Keycloak::Client.realm}/admin/user-groups"
        Keycloak.generic_request(token["access_token"], request_uri, nil, nil, "GET")
      }

      default_call(proc)
    end
  end
end

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
    user_groups = all_user_groups

    JSON.parse(response).map do |user|
      { id: user["id"], email: user["email"], groups: user_groups[user["id"]], first_name: user["firstName"], last_name: user["lastName"] }
    end
  end

  def all_organisations
    groups = all_groups
    organisations = groups.find { |group| group["name"] == "Organisations" }

    organisations["subGroups"].map do |organisation|
      { id: organisation["id"], name: organisation["name"], path: organisation["path"] }
    end
  end

  def all_groups
    response = Rails.cache.fetch(:keycloak_groups, expires_in: 5.minutes) do
      Keycloak::Internal.get_groups
    end

    JSON.parse(response)
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
    { id: user["sub"], email: user["email"], groups: user["groups"], first_name: user["given_name"], last_name: user["family_name"] }
  end

  def has_role?(role)
    @client.has_role? role
  end

private

  def all_user_groups
    response = Rails.cache.fetch(:keycloak_user_groups, expires_in: 5.minutes) do
      Keycloak::Internal.get_user_groups
    end

    JSON.parse(response).collect { |user| [user["id"], user["groups"]] }.to_h
  end
end
