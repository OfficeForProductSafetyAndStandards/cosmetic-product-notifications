class User < ActiveHash::Base
  include ActiveHash::Associations

  field :first_name
  field :last_name
  field :email

  has_many :activities, dependent: :nullify
  has_many :investigations, dependent: :nullify, foreign_key: "assignee_id", inverse_of: :user
  has_many :user_sources, dependent: :delete

  def self.find_or_create(user)
    User.find_by(id: user[:id]) || User.create(user)
  end

  def self.all(options = {})
    begin
      self.data = KeycloakClient.instance.all_users
    rescue RuntimeError => error
      Logger.new(STDOUT).error "Failed to fetch users from Keycloak: #{error.message}"
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

  def self.get_assignees_select_options
    select_options = { '': nil }
    self.all.each do |u|
      display_string = u.get_assignee_display_string
      select_options[display_string] = u.id
    end
    select_options
  end

  def get_assignee_display_string
    "#{full_name} (#{email})"
  end
end
