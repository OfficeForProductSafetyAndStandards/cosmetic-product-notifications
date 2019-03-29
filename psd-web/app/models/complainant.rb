class Complainant < ApplicationRecord
  include SanitizationHelper
  belongs_to :investigation, optional: true

  before_validation { trim_line_endings(:name, :other_details) }
  validates :complainant_type, presence: { message: "Select complainant type" }
  validates :investigation, presence: true, on: %i[create update]
  validates :email_address, allow_blank: true, format: { with: URI::MailTo::EMAIL_REGEXP }, on: :complainant_details

  validates_length_of :name, maximum: 100
  validates_length_of :other_details, maximum: 10000

  def can_be_displayed?
    can_be_seen_by_current_user? || investigation.child_should_be_displayed?
  end

private

  def can_be_seen_by_current_user?
    return true if investigation.source&.user_has_gdpr_access?

    complainant_type != "Consumer"
  end
end
