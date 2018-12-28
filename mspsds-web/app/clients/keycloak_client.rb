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

  module Admin
    def self.get_groups(query_parameters = nil, access_token = nil)
      generic_get("groups/", query_parameters, access_token)
    end

    def self.get_group_members(group_id, access_token = nil)
      generic_get("groups/#{group_id}/members", nil, access_token)
    end
  end

  module Internal
    def self.get_groups(query_parameters = nil, client_id = '', secret = '')
      client_id = Keycloak::Client.client_id if client_id.blank?
      secret = Keycloak::Client.secret if secret.blank?

      proc = lambda {|token|
        Keycloak::Admin.get_groups(query_parameters, token["access_token"])
      }

      default_call(proc, client_id, secret)
    end

    def self.get_group_members(group_id, client_id = '', secret = '')
      client_id = Keycloak::Client.client_id if client_id.blank?
      secret = Keycloak::Client.secret if secret.blank?

      proc = lambda {|token|
        Keycloak::Admin.get_group_members(group_id, token["access_token"])
      }

      default_call(proc, client_id, secret)
    end
  end
end

class KeycloakClient
  include Singleton

  def initialize
    @client = Keycloak::Client
    super
  end

  def all_users(organisation_id = nil)
    if organisation_id.present?
      cache_key = "keycloak_users_organisation_#{organisation_id}"
      response = Rails.cache.fetch(cache_key, expires_in: 5.minutes) do
        Keycloak::Internal.get_group_members(organisation_id)
      end
    else
      response = Rails.cache.fetch(:keycloak_users, expires_in: 5.minutes) do
        Keycloak::Internal.get_users
      end
    end

    JSON.parse(response).map do |user|
      { id: user["id"], organisation_id: organisation_id, email: user["email"], first_name: user["firstName"], last_name: user["lastName"] }
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
end
