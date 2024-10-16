class ResponsiblePersonAddressLog < ApplicationRecord
  ADDRESS_FIELDS = %i[line_1 line_2 city county postal_code].freeze

  belongs_to :responsible_person, inverse_of: :address_logs

  scope :newest_first, -> { order(end_date: :desc) }

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

  def address_lines
    ADDRESS_FIELDS.map { |field| public_send(field) }.select(&:present?)
  end

private

  def end_date_after_start_date_validation
    return if start_date.blank? || end_date.blank?

    if end_date < start_date
      errors.add(:end_date, "End date must be after start date")
    end
  end

  # Start date represents the date-time when this address started being used.
  # End date represents the date when the address got replaced and archived in the log.
  def set_dates
    self.start_date ||= calculate_start_date
    self.end_date ||= Time.zone.now
  end

  # If previous address logs were set for the Responsible Person, the address was used since the latest
  # log entry got added.
  # If no previous address logs were set, the address was used since the creation of the Responsible Person.
  def calculate_start_date
    if (last_address_log = responsible_person.address_logs.order(end_date: :asc).last)
      last_address_log.end_date
    else
      responsible_person.created_at
    end
  end
end
