class Team < ActiveHash::Base
  include ActiveHash::Associations

  field :id
  field :name
  field :path
  field :team_recipient_email

  belongs_to :organisation

  has_many :team_users, dependent: :nullify
  has_many :users, through: :team_users

  has_many :investigations, dependent: :nullify, as: :assignable

  def users
    # has_many through seems not to work with ActiveHash
    # It's not well documented but the same fix has been suggested here: https://github.com/zilkey/active_hash/issues/25
    team_users.map(&:user)
  end

  def add_user(user_id)
    Shared::Web::KeycloakClient.instance.add_user_to_team user_id, id
    # Trigger reload of users and relations from KC
    User.load(force: true)
  end

  def self.load(force: false)
    Organisation.load(force: force)
    begin
      self.data = Shared::Web::KeycloakClient.instance.all_teams
    rescue StandardError => e
      Rails.logger.error "Failed to fetch teams from Keycloak: #{e.message}"
      self.data = nil
    end

    self.ensure_names_up_to_date
  end

  def self.all(options = {})
    self.load

    if options.has_key?(:conditions)
      where(options[:conditions])
    else
      @records ||= []
    end
  end

  def display_name(ignore_visibility_restrictions: false)
    return name if (User.current.organisation == organisation) || ignore_visibility_restrictions

    organisation.name
  end

  def full_name
    display_name
  end

  def assignee_short_name
    display_name
  end

  def self.ensure_names_up_to_date
    return if Rails.env.test?

    Rails.cache.fetch(:up_to_date, expires_in: 30.minutes) do
      Rails.application.config.team_names["organisations"]["opss"].each do |name|
        found = false
        self.data.each { |team_data| found = found || team_data[:name] == name }
        raise "Team name #{name} not found, if recently changed in Keycloak, please update important_team_names.yml" unless found
      end
      true
    end
  end

  def self.get_visible_teams(user)
    team_names = Rails.application.config.team_names["organisations"]["opss"]
    return Team.where(name: team_names) if user.is_opss?

    Team.where(name: team_names[0])
  end
end
Team.load if Rails.env.development?
