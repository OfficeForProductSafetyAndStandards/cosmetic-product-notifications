class Correspondence < ApplicationRecord
  include DateConcern
  include SanitizationHelper
  belongs_to :investigation, optional: true
  has_one :activity

  before_validation :strip_whitespace
  before_validation { trim_line_endings(:details) }

  validates :email_address, allow_blank: true, format: { with: URI::MailTo::EMAIL_REGEXP }, on: :context
  validates_presence_of :correspondence_date, on: :context
  validates_length_of :details, maximum: 50000

  def get_date_key
    :correspondence_date
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
    investigation.can_display_child_object?(has_consumer_info, source)
  end

  def source
    activity&.source
  end
end
