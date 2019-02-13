class EmailVerificationKey < ApplicationRecord
  belongs_to :responsible_person

  before_create :set_key
  before_create :set_expires_at

  def EmailVerificationKey.key_validity_duration
    return 1.day
  end

private

  def set_key
    new_key = nil
    loop do
      new_key = SecureRandom.urlsafe_base64
      break unless EmailVerificationKey.where(key: new_key).exists?
    end
    self.key = new_key
  end

  def set_expires_at
    self.expires_at = EmailVerificationKey.key_validity_duration.from_now
  end
end
