class Correspondence < ApplicationRecord
  include DateConcern
  belongs_to :investigation, required: false

  before_validation :strip_whitespace

  def get_date_key
    :correspondence_date
  end

  has_one_attached :email_file
  has_one_attached :email_attachment

  enum email_direction: {
      outbound: "Outbound",
      inbound: "Inbound"
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
