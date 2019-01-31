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

    name == "OPSS Enforcement" ? "The Office for Product Safety and Standards" : name
  end

  def full_name
    display_name
  end

  def assignee_short_name
    display_name
  end

  def self.get_visible_teams(user)
    return Team.where(name: ["OPSS Enforcement", "OPSS Processing", "OPSS Incident management"]) if user.is_opss?

    Team.where(name: ["OPSS Enforcement"])
  end
end
Team.all if Rails.env.development?
