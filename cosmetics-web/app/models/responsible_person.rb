class ResponsiblePerson < ApplicationRecord
  has_many :notifications, dependent: :destroy
  has_many :team_members, dependent: :destroy
  has_many :users, through: :team_members

  enum account_type: { business: "business", individual: "individual" }

  def add_team_member(user)
    team_members << TeamMember.create(user: user)
  end
end
