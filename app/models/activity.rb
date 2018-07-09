class Activity < ApplicationRecord
  default_scope { order(created_at: :desc) }
  belongs_to :investigation
  belongs_to :activity_type
  belongs_to :user, optional: true
end
