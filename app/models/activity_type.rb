class ActivityType < ApplicationRecord
  has_many :activities, dependent: :destroy
end
