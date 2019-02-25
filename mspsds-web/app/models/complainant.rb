class Complainant < ApplicationRecord
  belongs_to :investigation, optional: true

  before_validation :trim_end_line
  validates :complainant_type, presence: { message: "Select complainant type" }
  validates :investigation, presence: true, on: %i[create update]
  validates :email_address, allow_blank: true, format: { with: URI::MailTo::EMAIL_REGEXP }, on: :complainant_details

  validates_length_of :name, maximum: 1000
  validates_length_of :other_details, maximum: 1000

  def contains_personal_data?
    complainant_type == "Consumer"
  end

  def can_be_displayed?
    return true if investigation.source&.is_a? ReportSource
    return true unless contains_personal_data?
    return true if User.current.organisation == investigation&.source&.user&.organisation

    false
  end

private

  # Browsers treat end of line as one character when checking input length, but send it as \r\n, 2 characters
  # To keep max length consistent we need to reverse that
  def trim_end_line
    self.name = name.gsub("\r\n", "\n") if self.name
    self.other_details = other_details.gsub("\r\n", "\n") if self.other_details
  end
end
