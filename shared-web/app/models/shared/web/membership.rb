module Shared
  module Web
    class Membership < ActiveHash::Base
      include ActiveHash::Associations

      belongs_to :team
      belongs_to :user

      def self.all(options = {})
        begin
          self.data = Shared::Web::KeycloakClient.instance.all_memberships if self.data.blank?
        rescue StandardError => error
          Rails.logger.error "Failed to fetch organisations from Keycloak: #{error.message}"
          self.data = nil
        end

        if options.has_key?(:conditions)
          where(options[:conditions])
        else
          @records ||= []
        end
      end
    end
  end
end
