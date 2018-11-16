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

  def get_date_key
    :date_decided
  end

  # TODO MSPSDS-551: Confirm if summary and date_decided fields should be required
  validate :date_decided_cannot_be_in_the_future

  validates :investigation, presence: true
  validates :legislation, presence: true
  validates :business, presence: true
  validates :product, presence: true

  def date_decided_cannot_be_in_the_future
    errors.add(:date_decided, "can't be in the future") if
        date_decided.present? and date_decided > Date.today
  end
end
