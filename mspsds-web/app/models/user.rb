class User < ActiveHash::Base
  include ActiveHash::Associations

  field :first_name
  field :last_name
  field :email

  has_many :activities, dependent: :nullify
  has_many :investigations, dependent: :nullify, foreign_key: "assignee_id", inverse_of: :user
  has_many :user_sources, dependent: :delete

  belongs_to :organisation

  def self.find_or_create(attributes)
    groups = attributes.delete(:groups)
    organisation = Organisation.find_by_path(groups)
    User.find_by(id: attributes[:id]) || User.create(attributes.merge(organisation_id: organisation&.id))
  end

  def self.all(options = {})
    begin
      organisations = Organisation.all
      all_users = organisations.flat_map do |organisation|
        KeycloakClient.instance.all_users(organisation.id)
      end
      all_users.concat(KeycloakClient.instance.all_users)

      self.data = all_users.uniq { |user| user[:id] }
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

  def full_name
    "#{first_name} #{last_name}"
  end

  def has_role?(role)
    KeycloakClient.instance.has_role? role
  end

  def self.get_assignees_select_options(except_those_users = [])
    select_options = { '': nil }

    (self.all - (except_those_users || [])).each do |user|
      display_string = user.get_assignee_display_string
      select_options[display_string] = user.id
    end
    select_options
  end

  def self.get_assignees_select_options_short(except_those_users = [])
    select_options = { '': nil }
    (self.all - (except_those_users || [])).each do |user|
      display_string = user.full_name
      select_options[display_string] = user.id
    end
    select_options
  end

  def get_assignee_display_string
    "#{full_name} (#{email})"
  end
end
