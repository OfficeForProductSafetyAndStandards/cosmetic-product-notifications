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

  def display_name
    display_name = full_name
    display_name += " (#{organisation.name})" if organisation.present?
    display_name
  end

  def has_role?(role)
    KeycloakClient.instance.has_role? role
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
