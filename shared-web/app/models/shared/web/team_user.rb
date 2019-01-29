module Shared
  module Web
    class TeamUser < ActiveHash::Base
      include ActiveHash::Associations

      belongs_to :team
      belongs_to :user

      def self.all(options = {})
        # This condition is to limit number of calls when Rails creates Active Hash for TeamUsers
        if @previous_time.blank? || (Time.current - @previous_time).to_i > 5 * 60
          @previous_time = Time.current
          begin
            self.data = Shared::Web::KeycloakClient.instance.all_team_users
          rescue StandardError => error
            Rails.logger.error "Failed to fetch team memberships from Keycloak: #{error.message}"
            self.data = nil
          end
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
