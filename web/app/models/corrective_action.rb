class CorrectiveAction < ApplicationRecord
  include DateConcern

  belongs_to :investigation
  belongs_to :business
  belongs_to :product

  has_many_attached :documents

  attribute :day, :integer
  attribute :month, :integer
  attribute :year, :integer
  validate :date_from_components
end
