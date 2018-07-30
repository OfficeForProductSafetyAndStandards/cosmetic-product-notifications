class User < ActiveHash::Base
  include ActiveHash::Associations

  field :first_name
  field :last_name
  field :email

  has_many :activities, dependent: :nullify
  has_many :investigations, dependent: :nullify, foreign_key: "assignee_id", inverse_of: :user
  has_many :user_sources, dependent: :delete

  def self.find_or_create(id, email, first_name, last_name)
    User.find(id) || User.create(id: id, email: email, first_name: first_name, last_name: last_name)
  end

  def full_name
    "#{first_name} #{last_name}"
  end

  def has_role?(role)
    Keycloak::Client.has_role? role
  end
end
