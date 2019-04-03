class Correspondence < ApplicationRecord
  include DateConcern
  include SanitizationHelper
  belongs_to :investigation, optional: true
  has_one :activity, dependent: :destroy

  before_validation :strip_whitespace
  before_validation { trim_line_endings(:details) }

  validates :email_address, allow_blank: true, format: { with: URI::MailTo::EMAIL_REGEXP }, on: :context
  validates_length_of :details, maximum: 50000

  def date_keys
    [:correspondence_date]
  end

  has_many_attached :documents

  enum contact_method: {
    email: "Email",
    phone: "Phone call"
  }, _suffix: true

  def strip_whitespace
    changed.each do |attribute|
      if send(attribute).respond_to?(:strip)
        send("#{attribute}=", send(attribute).strip)
      end
    end
  end

  def can_be_displayed?
    can_be_seen_by_current_user? || investigation.child_should_be_displayed?
  end

private

  def can_be_seen_by_current_user?
    return true if activity&.source&.user_has_gdpr_access?

    !has_consumer_info
  end
end
