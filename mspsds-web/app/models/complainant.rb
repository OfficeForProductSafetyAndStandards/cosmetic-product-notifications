class Complainant < ApplicationRecord
  belongs_to :investigation, optional: true

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
end
