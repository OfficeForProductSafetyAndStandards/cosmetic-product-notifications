class User < ActiveHash::Base
  include ActiveHash::Associations
  include Searchable

  index_name [Rails.env, "users"].join("_")

  field :first_name
  field :last_name
  field :email

  has_many :activities, dependent: :nullify
  has_many :investigations, dependent: :nullify, foreign_key: "assignee_id", inverse_of: :user
  has_many :user_sources, dependent: :delete

  def self.find_or_create(user)
    User.find_by(id: user[:id]) || User.create(user)
  end

  def full_name
    "#{first_name} #{last_name}"
  end

  def has_role?(role)
    KeycloakClient.instance.has_role? role
  end
end
