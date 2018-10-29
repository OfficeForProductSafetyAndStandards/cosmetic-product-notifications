class Reporter < ApplicationRecord
  belongs_to :investigation, required: false
  validates :investigation, presence: true, on: %i[create update]
  validates :email_address, allow_blank: true, format: { with: URI::MailTo::EMAIL_REGEXP }, on: :questioner_details
  # To validate something on specific step pass this step as context and use on: as below
  # validates :name, presence: true, on: %i[create update details]
end
