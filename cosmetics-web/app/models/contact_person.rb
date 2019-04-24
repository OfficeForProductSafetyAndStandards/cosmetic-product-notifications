class ContactPerson < ApplicationRecord
  belongs_to :responsible_person

  validates :name, presence: true
  validates :email_address, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :phone_number, presence: true

  before_create :current_user_is_verified

private

  def current_user_is_verified
    self.is_email_verified = true if email_address == User.current&.email
  end
end
