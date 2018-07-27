class User < ApplicationRecord
  include Searchable

  index_name [Rails.env, "users"].join("_")

  default_scope { order(created_at: :desc) }
  has_many :user_source, dependent: :nullify

  def initialize
    userinfo = JSON(Keycloak::Client.get_userinfo)
    @user_id = userinfo[:sub]
    @email = userinfo[:email]
  end

  def self.all
    Keycloak::Internal.get_users
  end

  def self.find(email)
    Keycloak::Internal.get_user_info(email)
  end

  def has_role?(role)
    Keycloak::Client.has_role? role
  end
end
