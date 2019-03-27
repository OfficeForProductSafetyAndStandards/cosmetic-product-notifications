class TeamUser < ActiveHash::Base
  include ActiveHash::Associations

  belongs_to :team
  belongs_to :user

  def self.all(options = {})
    begin
      self.data = Shared::Web::KeycloakClient.instance.all_team_users(force: options[:force])
    rescue StandardError => error
      Rails.logger.error "Failed to fetch team memberships from Keycloak: #{error.message}"
      self.data = nil
    end
    if options.has_key?(:conditions)
      where(options[:conditions])
    else
      @records ||= []
    end
  end
end
TeamUser.all if Rails.env.development?
