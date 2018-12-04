class Reporter < ApplicationRecord
  belongs_to :investigation, required: false

  validates :reporter_type, presence: true
  validates :investigation, presence: true, on: %i[create update]
  validates :email_address, allow_blank: true, format: { with: URI::MailTo::EMAIL_REGEXP }, on: :reporter_details

  validates_length_of :name, maximum: 1000
  validates_length_of :other_details, maximum: 1000
end
