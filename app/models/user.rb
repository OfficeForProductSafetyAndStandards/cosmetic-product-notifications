class User < ApplicationRecord
  royce_roles %w[user admin]
  before_create :set_default_role

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :recoverable,
         :rememberable, :trackable, :validatable

  private

  def set_default_role
    add_role :user
  end
end
