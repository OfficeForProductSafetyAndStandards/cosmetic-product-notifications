class EmailVerificationKey < ApplicationRecord
  belongs_to :responsible_person

  before_create :set_key
  before_create :set_expires_at

  def self.key_validity_duration
    1.day
  end

  def is_expired?
    expires_at < DateTime.current
  end

  def self.verify_key_for_responsible_person(responsible_person_id, key)
    EmailVerificationKey.find_by!(
      "responsible_person_id = ? AND key = ? AND expires_at >= ?",
      responsible_person_id, key, DateTime.current
    )
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
