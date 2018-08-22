require "elasticsearch/model"

class User < ApplicationRecord
  include Searchable

  index_name [Rails.env, "users"].join("_")

  settings index: { number_of_shards: 1 } do
    mappings do
      indexes :email, type: :keywords
    end
  end

  default_scope { order(created_at: :desc) }
  has_many :user_source, dependent: :nullify

  rolify
  after_create :set_default_role

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :invitable, :database_authenticatable, :recoverable,
         :rememberable, :trackable, :validatable

  private

  def set_default_role
    add_role(:user) if roles.blank?
  end
end
