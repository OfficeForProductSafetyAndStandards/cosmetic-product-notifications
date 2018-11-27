class Correspondence < ApplicationRecord
  include DateConcern
  belongs_to :investigation, required: false

  before_validation :strip_whitespace

  validates :email_address, allow_blank: true, format: { with: URI::MailTo::EMAIL_REGEXP }, on: :context
  validates_presence_of :correspondence_date
  validates_length_of :details, maximum: 1000

  def get_date_key
    :correspondence_date
  end

  has_many_attached :documents

  enum email_direction: {
      outbound: "To",
      inbound: "From"
  }

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
end
