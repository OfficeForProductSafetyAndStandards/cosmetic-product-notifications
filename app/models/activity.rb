class Activity < ApplicationRecord
  default_scope { order(created_at: :desc) }
  belongs_to :investigation
  belongs_to :activity_type
  has_one :source, as: :sourceable, dependent: :destroy

  accepts_nested_attributes_for :source

  has_paper_trail
end
