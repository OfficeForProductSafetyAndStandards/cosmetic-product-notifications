class Incident < ApplicationRecord
  include DateHelper
  belongs_to :investigation

  # TODO This date logic (and the related view) ought to be split out into a reusable utility
  attribute :day, :integer
  attribute :month, :integer
  attribute :year, :integer
  validate :date_from_components

  after_initialize do
    helper_after_initialize
  end
end
