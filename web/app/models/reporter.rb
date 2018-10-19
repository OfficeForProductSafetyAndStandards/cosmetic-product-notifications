class Reporter < ApplicationRecord
  belongs_to :investigation, required: false
  validates :investigation, presence: true, on: %i[create update]
  # To validate something on specific step pass this step as context and use on: as below
  # validates :name, presence: true, on: %i[create update details]
end
