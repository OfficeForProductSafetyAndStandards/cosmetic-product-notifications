class Correspondence < ApplicationRecord
  include DateConcern
  belongs_to :investigation, required: false

  attribute :day, :integer
  attribute :month, :integer
  attribute :year, :integer
  validate :date_from_components

  def get_date_key
    :correspondence_date
  end

  has_many_attached :documents
  has_one_attached :email_files
  has_many_attached :email_attachments

  enum email_direction: {
      outbound: "Outbound",
      inbound: "Inbound"
  }

  enum contact_method: {
    email: "Email",
    phone: "Phone call"
  }, _suffix: true
end
