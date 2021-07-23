class PendingResponsiblePersonUser < ApplicationRecord
  INVITATION_TOKEN_VALID_FOR = 3 * 24 * 3600 # 3 days
  EMAIL_ERROR_MESSAGE_SCOPE = %i[activerecord errors models pending_responsible_person_user attributes email_address].freeze

  belongs_to :inviting_user, class_name: :SubmitUser, inverse_of: :pending_responsible_person_users
  belongs_to :responsible_person

  validates :email_address,
            email: { message: :wrong_format, if: -> { email_address.present? } },
            presence: true,
            uniqueness: { scope: [:responsible_person], message: :taken }
  validate :email_address_not_in_team?

  before_create :generate_token
  before_create :remove_duplicate

  def self.key_validity_duration
    1.day
  end

  def expired?
    invitation_token_expires_at && invitation_token_expires_at < Time.zone.now
  end

  def refresh_token_expiration!
    self.invitation_token_expires_at = Time.zone.now + INVITATION_TOKEN_VALID_FOR.seconds
    save!
  end

private

  def generate_token
    token = SecureRandom.uuid
    self.invitation_token = token
    self.invitation_token_expires_at = Time.zone.now + INVITATION_TOKEN_VALID_FOR.seconds
  end

  def email_address_not_in_team?
    if responsible_person.has_user_with_email?(email_address)
      errors.add :email_address, I18n.t(:taken_team, scope: EMAIL_ERROR_MESSAGE_SCOPE)
    end
  end

  def remove_duplicate
    PendingResponsiblePersonUser.where(
      responsible_person_id: responsible_person.id,
      email_address: email_address,
      inviting_user: inviting_user,
    ).delete_all
  end
end
