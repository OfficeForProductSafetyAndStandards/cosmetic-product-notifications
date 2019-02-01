class Team < ActiveHash::Base
  include ActiveHash::Associations
  include UserService

  field :id
  field :name
  field :path

  belongs_to :organisation

  has_many :team_users, dependent: :nullify
  has_many :users, through: :team_users

  has_many :investigations, dependent: :nullify, as: :assignable

  def users
    # has_many through seems not to work with ActiveHash
    # It's not well documented but the same fix has been suggested here: https://github.com/zilkey/active_hash/issues/25
    team_users.map(&:user)
  end

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

  def display_name
    return name if current_user.organisation == organisation

    organisation.name
  end

  def full_name
    display_name
  end

  def assignee_short_name
    display_name
  end

  def self.get_visible_teams(user)
    return Team.find_teams_in_organisation(%w[Enforcement Processing Incident], "Safety and Standards") if user.is_opss?

    Team.find_teams_in_organisation(%w[Enforcement], "Safety and Standards")
  end

  def self.find_teams_in_organisation(team_names, organisation_name)
    Team.all.select do |team|
      found = false
      team_names.each do |name|
        found = found || (team.name.downcase.include? name.downcase)
      end
      found && (team.organisation.name.downcase.include? organisation_name.downcase)
    end
  end
end
Team.all if Rails.env.development?
