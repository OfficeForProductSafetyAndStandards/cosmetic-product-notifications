# UnusedCodeAlerting
# Doesn't have a matching table on the database
# This file/model is dangling and should be removed
class EmailVerificationKey < ApplicationRecord
  belongs_to :contact_person

  before_create :set_key
  before_create :set_expires_at

  def self.key_validity_duration
    UnusedCodeAlerting.alert
    1.day
  end

  def is_expired?
    UnusedCodeAlerting.alert
    expires_at < Time.zone.now
  end

private

  def set_key
    UnusedCodeAlerting.alert
    new_key = nil
    loop do
      new_key = SecureRandom.urlsafe_base64
      break unless EmailVerificationKey.where(key: new_key).exists?
    end
    self.key = new_key
  end

  def set_expires_at
    UnusedCodeAlerting.alert
    self.expires_at = EmailVerificationKey.key_validity_duration.from_now
  end
end
