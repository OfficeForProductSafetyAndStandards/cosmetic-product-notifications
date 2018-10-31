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

  enum contact_method: {
    email: "Email",
    phone: "Phone call"
  }, _suffix: true
end
