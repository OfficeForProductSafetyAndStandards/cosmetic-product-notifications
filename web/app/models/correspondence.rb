class Correspondence < ApplicationRecord
  include DateHelper
  belongs_to :investigation, required: false

  attribute :day, :integer
  attribute :month, :integer
  attribute :year, :integer
  validate :date_from_components

  after_initialize do
    set_keys(:correspondence_date)
    helper_after_initialize
  end
end
