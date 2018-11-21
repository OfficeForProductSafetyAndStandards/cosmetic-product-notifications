class Correspondence < ApplicationRecord
  include DateConcern
  belongs_to :investigation, required: false

  before_validation :strip_whitespace

  def get_date_key
    :correspondence_date
  end

  has_many_attached :documents

  enum email_direction: {
      outbound: "Outbound",
      inbound: "Inbound"
  }

  enum contact_method: {
    email: "Email",
    phone: "Phone call"
  }, _suffix: true

  def find_attachment_by_name name
    documents.find { |attachment| attachment.metadata[:attachment_name] == name }
  end

  def strip_whitespace
    changed.each do |attribute|
      if send(attribute).respond_to?(:strip)
        send("#{attribute}=", send(attribute).strip)
      end
    end
  end
end
