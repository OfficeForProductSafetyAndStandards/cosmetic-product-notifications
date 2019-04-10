class TeamUser < ActiveHash::Base
  include ActiveHash::Associations

  belongs_to :team
  belongs_to :user

  def self.load(force: false)
    begin
      self.data = Shared::Web::KeycloakClient.instance.all_team_users(Team.all.map(&:id), force: :force)
    rescue StandardError => e
      Rails.logger.error "Failed to fetch team memberships from Keycloak: #{e.message}"
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
end
TeamUser.load if Rails.env.development?
