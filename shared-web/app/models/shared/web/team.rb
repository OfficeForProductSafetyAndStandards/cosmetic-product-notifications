module Shared
  module Web
    class Team < ActiveHash::Base
      include ActiveHash::Associations

      field :id
      field :name
      field :path

      belongs_to :organisation

      has_many :users, dependent: :nullify

      def self.all(options = {})
        begin
          self.data = Shared::Web::KeycloakClient.instance.all_teams
        rescue StandardError => error
          Rails.logger.error "Failed to fetch teams from Keycloak: #{error.message}"
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
