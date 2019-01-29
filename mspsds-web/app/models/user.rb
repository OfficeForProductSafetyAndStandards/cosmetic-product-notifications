class User < Shared::Web::User
  has_many :activities, dependent: :nullify
  has_many :investigations, dependent: :nullify, foreign_key: "assignee_id", inverse_of: :user
  has_many :user_sources, dependent: :delete

  include UserService

  def self.find_or_create(attributes)
    groups = attributes.delete(:groups)
    organisation = Organisation.find_by_path(groups) # rubocop:disable Rails/DynamicFindBy
    user = User.find_by(id: attributes[:id]) || User.create(attributes.merge(organisation_id: organisation&.id))
    TeamUser.all
    user
  end

  def self.all(options = {})
    begin
      all_users = Shared::Web::KeycloakClient.instance.all_users
      self.data = all_users.map { |user| populate_organisation(user) }
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

  def display_name
    display_name = full_name
    can_display_teams = organisation.present? && current_user.organisation&.id == organisation.id && teams.any?
    membership_display = can_display_teams ? teams.map(&:name).join(', ') : organisation&.name
    display_name += " (#{membership_display})" if membership_display.present?
    display_name
  end

  def assignee_short_name
    if organisation.present? && organisation.id != current_user&.organisation&.id
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

  def self.get_assignees_select_options(except: [], use_short_name: false)
    users_to_exclude = Array(except)

    select_options = { '': nil }
    (self.all - users_to_exclude).each do |user|
      label = use_short_name ? user.full_name : user.display_name
      select_options[label] = user.id
    end
    select_options
  end
end
User.all if Rails.env.development?
