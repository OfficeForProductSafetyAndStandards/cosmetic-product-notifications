class PendingResponsiblePersonUser < ApplicationRecord
  belongs_to :responsible_person

  validates :email_address, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  
  before_create :set_expires_at

  def self.key_validity_duration
    1.day
  end

private

  def set_expires_at
    self.expires_at = PendingResponsiblePersonUser.key_validity_duration.from_now
  end
end
