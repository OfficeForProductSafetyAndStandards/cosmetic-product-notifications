module Shared
  module Web
    class Organisation < ActiveHash::Base
      include ActiveHash::Associations

      field :id
      field :name
      field :path

      has_many :users, dependent: :nullify

      def self.all(options = {})
        begin
          self.data = Shared::Web::KeycloakClient.instance.all_organisations
        rescue StandardError => e
          Rails.logger.error "Failed to fetch organisations from Keycloak: #{e.message}"
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
