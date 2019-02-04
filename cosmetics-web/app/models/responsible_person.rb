class ResponsiblePerson < ApplicationRecord
  has_many :notifications, dependent: :destroy
  has_many :notification_files, dependent: :destroy
  has_many :team_members, dependent: :destroy
  has_many :users, through: :team_members
end
