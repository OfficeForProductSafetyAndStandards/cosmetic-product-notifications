class ActivityType < ApplicationRecord
  has_many :activities, dependent: :destroy

  def titleized_name
    name.titleize
  end
end
