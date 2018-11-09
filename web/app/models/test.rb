class Test < ApplicationRecord
  include DateConcern

  belongs_to :investigation
  belongs_to :product

  enum status: %i[requested passed failed]

  has_many_attached :documents

  attribute :day, :integer
  attribute :month, :integer
  attribute :year, :integer
  validate :date_from_components
end
