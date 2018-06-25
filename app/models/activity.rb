class Activity < ApplicationRecord
  belongs_to :investigation
  belongs_to :activity_type
end
