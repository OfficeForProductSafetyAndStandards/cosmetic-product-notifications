class PendingResponsiblePersonUser < ApplicationRecord
  INVITATION_TOKEN_VALID_FOR = 3 * 24 * 3600 # 3 days

  belongs_to :responsible_person

  validates :email_address, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validate :email_address_is_not_in_team?

  before_create :generate_token
  before_create :remove_duplicate_pending_responsible_users

  def self.key_validity_duration
    1.day
  end

  def self.pending_requests_to_join_responsible_person(user, responsible_person)
    PendingResponsiblePersonUser.where(
      "email_address = ? AND responsible_person_id = ? AND expires_at > ?",
      user.email,
      responsible_person.id,
      DateTime.current,
    )
  end

private

  def generate_token
    token = SecureRandom.uuid
    self.invitation_token = token
    self.invitation_token_expires_at = Time.now.utc + INVITATION_TOKEN_VALID_FOR.seconds
  end

  def email_address_is_not_in_team?
    # TODO: Move errors to en.yml file
    if responsible_person.responsible_person_users.any? { |user| user.email_address == email_address }
      errors.add :email_address, "The email address is already a member of this team"
    elsif email_associated_to_any_team?
      errors.add :email_address, "The email address is already a member of a team"
    end
  end

  def email_associated_to_any_team?
    user = User.find_by(email: email_address)
    user && user.responsible_persons.any?
  end

  def remove_duplicate_pending_responsible_users
    PendingResponsiblePersonUser.where(
      responsible_person_id: responsible_person.id,
      email_address: email_address,
    ).delete_all
  end
end
