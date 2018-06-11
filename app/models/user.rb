class User < ApplicationRecord
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
