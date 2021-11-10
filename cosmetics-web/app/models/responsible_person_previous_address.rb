class ResponsiblePersonPreviousAddress < ApplicationRecord
  belongs_to :responsible_person, inverse_of: :previous_addresses

  validates :line_1, presence: true
  validates :city, presence: true
  validates :postal_code, presence: true
  validates :postal_code, uk_postcode: true, if: -> { postal_code.present? }
  validates :start_date, presence: true
  validates :end_date, presence: true
  validate :end_date_after_start_date_validation

  before_validation :set_dates

  def to_s
    [line_1, line_2, city, county, postal_code].select(&:present?).join(", ")
  end

private

  def end_date_after_start_date_validation
    return if start_date.blank? || end_date.blank?

    if end_date < start_date
      errors.add(:end_date, "End date must be after start date")
    end
  end

  # Start date represents the date-time when this address started being used.
  # End date represents the date when the address got replaced and archived as previous address.
  def set_dates
    self.start_date ||= calculate_start_date
    self.end_date ||= Time.zone.now
  end

  # If previous addresses were set for the Responsible Person, the address was used since the latest
  # previous address got replaced/archived/ended.
  # If no previous addresses were set, the address was used since the creation of the responsible person.
  def calculate_start_date
    if (last_previous_address = responsible_person.previous_addresses.order(end_date: :asc).last)
      last_previous_address.end_date
    else
      responsible_person.created_at
    end
  end
end
