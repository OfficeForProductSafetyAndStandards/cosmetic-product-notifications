class Correspondence < ApplicationRecord
  include DateConcern
  belongs_to :investigation, required: false

  attribute :day, :integer
  attribute :month, :integer
  attribute :year, :integer
  validate :date_from_components

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

  def find_attachment_by_category category
    documents.find { |attachment| attachment.metadata[:attachment_category] == category }
  end

  def strip_whitespace
    changed.each do |attribute|
      if send(attribute).respond_to?(:strip)
        send("#{attribute}=", send(attribute).strip)
      end
    end
  end
end
