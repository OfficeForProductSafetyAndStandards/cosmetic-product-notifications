class Reporter < ApplicationRecord
  belongs_to :investigation, required: false
  validates :investigation, presence: true, on: [:create, :update]
  validates :reporter_type, presence: true
  validates :name, presence: true, if: -> { step != :type }
  attr_accessor :step
end
