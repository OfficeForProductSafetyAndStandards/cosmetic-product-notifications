class ResponsiblePerson < ApplicationRecord
  has_many :notifications, dependent: :destroy
  has_many :team_members, dependent: :destroy
end
