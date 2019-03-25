class User < Shared::Web::User
  has_many :activities, dependent: :nullify
  has_many :investigations, dependent: :nullify, as: :assignable
  has_many :user_sources, dependent: :delete

  has_many :team_users, dependent: :nullify
  has_many :teams, through: :team_users

  has_one :user_attributes, dependent: :destroy

  # Getters and setters for each UserAttributes column should be added here so they can be accessed directly
  # from the User object via delegation.
  delegate :has_viewed_introduction, :has_viewed_introduction!, to: :get_user_attributes

  def teams
    # has_many through seems not to work with ActiveHash
    # It's not well documented but the same fix has been suggested here: https://github.com/zilkey/active_hash/issues/25
    team_users.map(&:team)
  end

  def self.create_and_send_invite(email_address, team, redirect_url)
    Shared::Web::KeycloakClient.instance.create_user email_address
    # We can't use User.all here to load the new user
    # - they're not part of any organisation yet, so aren't considered a mspsds user
    user_id = Shared::Web::KeycloakClient.instance.get_user(email_address)[:id]
    # Adding team membership will trigger user reload, too
    team.add_user user_id
    Shared::Web::KeycloakClient.instance.send_required_actions_welcome_email user_id, redirect_url
  end

  def self.find_or_create(attributes)
    groups = attributes.delete(:groups)
    organisation = Organisation.find_by(path: groups)
    user = User.find_by(id: attributes[:id]) || User.create(attributes.merge(organisation_id: organisation&.id))
    user
  end

  def self.all(options = {})
    begin
      all_users = Shared::Web::KeycloakClient.instance.all_users(force: options[:force])
      self.data = all_users.map { |user| populate_organisation(user) }
                      .reject { |user| user[:organisation_id].blank? }
      Team.all
      TeamUser.all(force: options[:force])
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

  def is_mspsds_user?
    has_role? :mspsds_user
  end

  def is_opss?
    has_role? :opss_user
  end

  def is_team_admin?
    has_role? :team_admin
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

  def get_user_attributes
    UserAttributes.find_or_create_by(user_id: id)
  end
end

User.all if Rails.env.development?
