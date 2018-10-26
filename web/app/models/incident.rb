class Incident < ApplicationRecord
  include DateConcern
  belongs_to :investigation

  attribute :day, :integer
  attribute :month, :integer
  attribute :year, :integer
  validate :date_from_components
end
