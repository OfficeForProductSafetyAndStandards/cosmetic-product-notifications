class Incident < ApplicationRecord
  include DateHelper
  belongs_to :investigation

  attribute :day, :integer
  attribute :month, :integer
  attribute :year, :integer
  validate :date_from_components

  after_initialize do
    helper_after_initialize
  end
end
