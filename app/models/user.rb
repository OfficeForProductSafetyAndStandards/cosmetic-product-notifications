class User < ActiveHash::Base
  include ActiveHash::Associations
  include Searchable

  index_name [Rails.env, "users"].join("_")

  field :first_name
  field :last_name
  field :email

  has_many :activities
  has_many :investigations, foreign_key: "assignee_id"
  has_many :user_sources

  def self.find_or_create(id, email, first_name, last_name)
    user = User.find_by_id id
    if user == nil
      user = User.create(id: id, email: email, first_name: first_name, last_name: last_name)
    end
    return user
  end

  def full_name
    "#{first_name} #{last_name}"
  end

  def has_role?(role)
    Keycloak::Client.has_role? role
  end
end
