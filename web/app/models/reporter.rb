class Reporter < ApplicationRecord
  belongs_to :investigation, required: false
  validates :investigation, presence: true, on: %i[create update]
  validates :reporter_type, presence: true
  validates :name, presence: true, on: %i[create update details]
end
