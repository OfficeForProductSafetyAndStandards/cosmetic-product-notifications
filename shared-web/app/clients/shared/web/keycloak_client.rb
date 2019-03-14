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

  module Internal
    def self.get_group(group_id)
      proc = lambda { |token|
        request_uri = Keycloak::Admin.full_url("groups/#{group_id}")
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

    def self.add_user_group(user_id, group_id)
      proc = lambda { |token|
        request_uri = Keycloak::Admin.full_url("users/#{user_id}/groups/#{group_id}")
        Keycloak.generic_request(token["access_token"], request_uri, nil, nil, "PUT")
      }
      default_call(proc)
    end

    def self.create_user(user_rep)
      proc = lambda { |token|
        request_uri = Keycloak::Admin.full_url("users/")
        Keycloak.generic_request(token["access_token"], request_uri, nil, user_rep, "POST")
      }
      default_call(proc)
    end

    def self.execute_actions_email(user_id, actions, client_id, redirect_uri)
      proc = lambda { |token|
        request_uri = Keycloak::Admin.full_url("users/#{user_id}/execute-actions-email")
        query_params = { client_id: client_id, redirect_uri: redirect_uri }
        Keycloak.generic_request(token["access_token"], request_uri, query_params, actions, "PUT")
      }
      default_call(proc)
    end
  end
end

module Shared
  module Web
    class KeycloakClient
      include Singleton

      def initialize
        # The gem we're using has its api split across these three classes
        @client = Keycloak::Client
        @admin = Keycloak::Admin
        @internal = Keycloak::Internal
        super
      end

      def all_users(force: false)
        Rails.cache.delete(:keycloak_users) if force
        response = Rails.cache.fetch(:keycloak_users, expires_in: 5.minutes) do
          Keycloak::Internal.get_users
        end
        user_groups = all_user_groups(force: force)

        JSON.parse(response).map do |user|
          { id: user["id"], email: user["email"], groups: user_groups[user["id"]], first_name: user["firstName"], last_name: user["lastName"] }
        end
      end

      def all_organisations
        groups = all_groups
        organisations = groups.find { |group| group["name"] == "Organisations" }

        organisations["subGroups"].reject(&:blank?).map do |organisation|
          { id: organisation["id"], name: organisation["name"], path: organisation["path"] }
        end
      end

      def all_teams
        groups = all_groups
        organisations = groups.find { |group| group["name"] == "Organisations" }

        teams = []
        organisations["subGroups"].reject(&:blank?).each do |organisation|
          organisation["subGroups"].reject(&:blank?).map do |team|
            team_recipient_email = group_attributes(team["id"])["teamRecipientEmail"]&.first
            teams << { id: team["id"], name: team["name"], path: team["path"], organisation_id: organisation["id"], team_recipient_email: team_recipient_email }
          end
        end
        teams
      end

      def all_team_users(force: false)
        users = all_users(force: force)
        user_groups = all_user_groups(force: force)
        teams = all_teams.map { |t| t[:id] }.to_set

        # We set ids manually because if we don't ActiveHash will use 'next_id' method when computing @records,
        # which calls TeamUser.all, and gets into an infinite loop
        team_users = []
        id = 1
        users.reject(&:blank?).each do |user|
          user_groups[user[:id]].reject(&:blank?).each do |group|
            team_users << { team_id: group, user_id: user[:id], id: id } if teams.include? group
            id += 1
          end
        end
        team_users
      end

      def group_attributes(group_id)
        cache_key = "keycloak_group_#{group_id}".to_sym
        response = Rails.cache.fetch(cache_key, expires_in: 5.minutes) do
          Keycloak::Internal.get_group(group_id)
        end
        JSON.parse(response)["attributes"] || {}
      end

      def registration_url(redirect_uri)
        params = URI.encode_www_form(client_id: Keycloak::Client.client_id, response_type: "code", redirect_uri: redirect_uri)
        Keycloak::Client.auth_server_url + "/realms/#{Keycloak::Client.realm}/protocol/openid-connect/registrations?#{params}"
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

      def has_role?(user_id, role)
        if User.current && (User.current.id == user_id)
          # This is faster, as it uses the already fetched claims
          @client.has_role? role
        else
          @internal.has_role? user_id, role
        end
      end

      def add_user_to_team(user_id, group_id)
        @internal.add_user_group user_id, group_id
      end

      def create_user(email)
        @internal.create_user email: email, username: email, enabled: true
      end

      def send_required_actions_welcome_email(user_id, redirect_uri)
        required_actions = %w(sms_auth_check_mobile UPDATE_PASSWORD UPDATE_PROFILE VERIFY_EMAIL)
        @internal.execute_actions_email user_id, required_actions, "mspsds-app", redirect_uri
      end

    private

      def all_user_groups(force: false)
        Rails.cache.delete(:keycloak_user_groups) if force
        response = Rails.cache.fetch(:keycloak_user_groups, expires_in: 5.minutes) do
          Keycloak::Internal.get_user_groups
        end

        JSON.parse(response).collect { |user| [user["id"], user["groups"]] }.to_h
      end

      def all_groups
        response = Rails.cache.fetch(:keycloak_groups, expires_in: 5.minutes) do
          Keycloak::Internal.get_groups
        end

        JSON.parse(response)
      end
    end
  end
end
