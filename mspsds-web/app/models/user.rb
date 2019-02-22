class User < Shared::Web::User
  has_many :activities, dependent: :nullify
  has_many :investigations, dependent: :nullify, as: :assignable
  has_many :user_sources, dependent: :delete

  has_many :team_users, dependent: :nullify
  has_many :teams, through: :team_users

  def teams
    # has_many through seems not to work with ActiveHash
    # It's not well documented but the same fix has been suggested here: https://github.com/zilkey/active_hash/issues/25
    team_users.map(&:team)
  end

  def self.find_or_create(attributes)
    groups = attributes.delete(:groups)
    organisation = Organisation.find_by_path(groups) # rubocop:disable Rails/DynamicFindBy
    user = User.find_by(id: attributes[:id]) || User.create(attributes.merge(organisation_id: organisation&.id))
    user
  end

  def self.all(options = {})
    begin
      all_users = Shared::Web::KeycloakClient.instance.all_users
      self.data = all_users.map { |user| populate_organisation(user) }
      Team.all
      TeamUser.all
    rescue StandardError => error
      Rails.logger.error "Failed to fetch users from Keycloak: #{error.message}"
      self.data = nil
    end

    if options.has_key?(:conditions)
      where(options[:conditions])
    else
      @records ||= []
    end
  end

  private_class_method def self.populate_organisation(attributes)
    groups = attributes.delete(:groups)
    teams = Team.where(id: groups)
    organisation = Organisation.find_by(id: groups) || Organisation.find_by(id: teams.first&.organisation_id)
    attributes.merge(organisation_id: organisation&.id)
  end

  def display_name(ignore_visibility_restrictions: false)
    display_name = full_name
    can_display_teams = ignore_visibility_restrictions || (organisation.present? && organisation.id == User.current.organisation&.id)
    can_display_teams = can_display_teams && teams.any?
    membership_display = can_display_teams ? team_names : organisation&.name
    display_name += " (#{membership_display})" if membership_display.present?
    display_name
  end

  def team_names
    teams.map(&:name).join(', ')
  end

  def assignee_short_name
    if organisation.present? && organisation.id != User.current.organisation&.id
      organisation.name
    else
      full_name
    end
  end

  def has_role?(role)
    Shared::Web::KeycloakClient.instance.has_role? role
  end

  def is_mspsds_user?
    has_role? :mspsds_user
  end

  def is_opss?
    has_role? :opss_user
  end

  def self.get_assignees(except: [])
    users_to_exclude = Array(except)
    self.all - users_to_exclude
  end

  def self.get_team_members(user:)
    users = [].to_set
    user.teams.each do |team|
      team.users.each do |team_member|
        users << team_member
      end
    end
    users
  end
end
User.all if Rails.env.development?
