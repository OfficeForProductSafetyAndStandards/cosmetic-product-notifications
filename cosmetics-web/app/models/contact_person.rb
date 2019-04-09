class ContactPerson < ApplicationRecord
  belongs_to :responsible_person

  validates :email_address, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :phone_number, presence: true
end
