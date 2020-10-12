class PendingResponsiblePersonUser < ApplicationRecord
  INVITATION_TOKEN_VALID_FOR = 3 * 24 * 3600 # 3 days
  EMAIL_ERROR_MESSAGE_SCOPE = %i[activerecord errors models pending_responsible_person_user attributes email_address].freeze

  belongs_to :responsible_person

  validates :email_address,
            email: {
              message: I18n.t(:wrong_format, scope: EMAIL_ERROR_MESSAGE_SCOPE),
              if: -> { email_address.present? },
            }
  validates_presence_of :email_address, message: I18n.t(:blank, scope: EMAIL_ERROR_MESSAGE_SCOPE)
  validate :email_address_not_in_team?
  validate :email_address_not_in_other_team?

  before_create :generate_token
  before_create :remove_duplicate_pending_responsible_users

  def self.key_validity_duration
    1.day
  end

  def expired?
    invitation_token_expires_at < DateTime.current
  end

  def refresh_token_expiration!
    self.invitation_token_expires_at = Time.now.utc + INVITATION_TOKEN_VALID_FOR.seconds
    self.save!
  end

private

  def generate_token
    token = SecureRandom.uuid
    self.invitation_token = token
    self.invitation_token_expires_at = Time.now.utc + INVITATION_TOKEN_VALID_FOR.seconds
  end

  def email_address_not_in_team?
    if responsible_person.responsible_person_users.any? { |user| user.email_address == email_address }
      errors.add :email_address, I18n.t(:this_team, scope: EMAIL_ERROR_MESSAGE_SCOPE)
    end
  end

  def email_address_not_in_other_team?
    user = SubmitUser.find_by(email: email_address)
    if user && user.responsible_persons.any?
      errors.add :email_address, I18n.t(:other_team, scope: EMAIL_ERROR_MESSAGE_SCOPE)
    end
  end

  def remove_duplicate_pending_responsible_users
    PendingResponsiblePersonUser.where(
      responsible_person_id: responsible_person.id,
      email_address: email_address,
    ).delete_all
  end
end
