module Shared
  module Web
    class User < ActiveHash::Base
      include ActiveHash::Associations

      belongs_to :organisation

      field :name
      field :email
      field :access_token

      def self.find_or_create(user)
        User.find_by(id: user[:id]) || User.create(user.except(:groups))
      end

      def self.load(force: false)
        begin
          self.data = Shared::Web::KeycloakClient.instance.all_users(force: force)
        rescue StandardError => e
          Rails.logger.error "Failed to fetch users from Keycloak: #{e.message}"
          self.data = nil
        end
      end

      def self.all(options = {})
        self.load

        if options.has_key?(:conditions)
          where(options[:conditions])
        else
          @records ||= []
        end
      end

      def self.current
        RequestStore.store[:current_user]
      end

      def self.current=(user)
        RequestStore.store[:current_user] = user
      end

      def has_role?(role)
        access_token = User.current.access_token if current_user?
        KeycloakClient.instance.has_role?(id, role, access_token)
      end

    private

      def current_user?
        User.current&.id == id
      end
    end
  end
end
