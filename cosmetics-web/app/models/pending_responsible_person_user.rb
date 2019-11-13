class PendingResponsiblePersonUser < ApplicationRecord
  belongs_to :responsible_person

  validates :email_address, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validate :email_address_is_not_in_team?

  before_create :set_expires_at
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

  def email_address_is_not_in_team?
    if responsible_person.responsible_person_users.any? { |user| user.email_address == email_address }
      errors.add :email_address, "The email address is already a member of this team"
    end
  end

  def set_expires_at
    self.expires_at = PendingResponsiblePersonUser.key_validity_duration.from_now
  end

  def remove_duplicate_pending_responsible_users
    PendingResponsiblePersonUser.where(
      responsible_person_id: responsible_person.id,
      email_address: email_address,
    ).delete_all
  end
end
