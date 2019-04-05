module Shared
  module Web
    class User < ActiveHash::Base
      include ActiveHash::Associations

      belongs_to :organisation

      field :first_name
      field :last_name
      field :email

      def self.find_or_create(user)
        User.find_by(id: user[:id]) || User.create(user.except(:groups))
      end

      def self.all(options = {})
        begin
          self.data = Shared::Web::KeycloakClient.instance.all_users
        rescue StandardError => e
          Rails.logger.error "Failed to fetch users from Keycloak: #{e.message}"
          self.data = nil
        end

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

      def full_name
        "#{first_name} #{last_name}"
      end

      def has_role?(role)
        KeycloakClient.instance.has_role? id, role
      end
    end
  end
end
