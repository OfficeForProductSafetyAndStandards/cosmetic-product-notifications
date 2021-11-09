class ResponsiblePersonPreviousAddress < ApplicationRecord
  belongs_to :responsible_person, inverse_of: :previous_addresses

  validates :line_1, presence: true
  validates :city, presence: true
  validates :postal_code, presence: true
  validates :postal_code, uk_postcode: true, if: -> { postal_code.present? }
  validates :start_date, presence: true
  validates :end_date, presence: true
end
