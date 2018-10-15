class Reporter < ApplicationRecord
  belongs_to :investigation, required: false
  validates :investigation, presence: true, if: -> { step != :type }
  validates :reporter_type, presence: true
  attr_accessor :step
end
