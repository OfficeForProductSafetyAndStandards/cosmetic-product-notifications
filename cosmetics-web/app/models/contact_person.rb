class ContactPerson < ApplicationRecord
  belongs_to :responsible_person

  has_one :email_verification_key, dependent: :destroy

  validates :name, presence: true
  validates :email_address, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :phone_number, presence: true

  before_update :reset_email_verified, if: -> { email_address_changed? }
  before_save :current_user_is_verified

private

  def reset_email_verified
    self.email_verified = false
  end

  def current_user_is_verified
    self.email_verified = true if email_address == User.current&.email
  end
end
