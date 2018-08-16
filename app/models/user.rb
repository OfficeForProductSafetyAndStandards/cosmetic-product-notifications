require "elasticsearch/model"

class User < ApplicationRecord
  include Elasticsearch::Model
  include Elasticsearch::Model::Callbacks

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

User.import force: true
