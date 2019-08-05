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
  delegate :has_accepted_declaration, :has_accepted_declaration!, to: :get_user_attributes
  delegate :has_been_sent_welcome_email, :has_been_sent_welcome_email!, to: :get_user_attributes

  def teams
    # Ensure we're serving up-to-date relations (modulo caching)
    TeamUser.load
    # has_many through seems not to work with ActiveHash
    # It's not well documented but the same fix has been suggested here: https://github.com/zilkey/active_hash/issues/25
    team_users.map(&:team)
  end

  def self.create_and_send_invite(email_address, team, redirect_url)
    Shared::Web::KeycloakClient.instance.create_user email_address
    # We can't use User.load here to load the new user
    # - they're not part of any organisation yet, so aren't considered a psd user
    user_id = Shared::Web::KeycloakClient.instance.get_user(email_address)[:id]
    team.add_user user_id
    # Now that user exists in a team, we can trigger a reload of users entities
    User.load(force: true)
    Shared::Web::KeycloakClient.instance.send_required_actions_welcome_email user_id, redirect_url
  end

  def self.find_or_create(attributes)
    groups = attributes.delete(:groups)
    organisation = Organisation.find_by(path: groups)
    user = User.find_by(id: attributes[:id]) || User.create(attributes.merge(organisation_id: organisation&.id))
    user
  end

  def self.load(force: false)
    begin
      all_users = Shared::Web::KeycloakClient.instance.all_users(force: force)
      # We're not interested in users not belonging to an organisation, as that means they are not PSD users
      # - however, checking this based on permissions would require a request per user
      # Some user object are missing their name when they have not finished their registration yet.
      # But we need to be able to show them on the teams page for example, so we ensure that the attribute is not nil
      self.data = all_users.deep_dup # We want a copy of the data to modify freely, not mutating the cached version
                      .map(&method(:populate_organisation))
                      .map(&method(:populate_name))
                      .reject { |user| user[:organisation_id].blank? }
    rescue StandardError => e
      Rails.logger.error "Failed to fetch users from Keycloak: #{e.message}"
      self.data = nil
    end
  end

  def self.populate_organisation(attributes)
    groups = attributes.delete(:groups)
    teams = Team.where(id: groups)
    organisation = Organisation.find_by(id: groups) || Organisation.find_by(id: teams.first&.organisation_id)
    attributes.merge(organisation_id: organisation&.id)
  end

  def self.populate_name(attributes)
    attributes[:name] ||= ""
    attributes
  end

  private_class_method :populate_organisation, :populate_name

  def display_name(ignore_visibility_restrictions: false)
    display_name = name
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
      name
    end
  end

  def is_psd_admin?
    has_role? :psd_admin
  end

  def is_psd_user?
    has_role? :psd_user
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

User.load if Rails.env.development?
