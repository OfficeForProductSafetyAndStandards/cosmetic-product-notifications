class SearchUser < User
  include Privileges::SearchConcern

  INVITATION_EXPIRATION_DAYS = 14
  ALLOW_INTERNATIONAL_PHONE_NUMBER = false
  TOTP_ISSUER = "Search Cosmetics".freeze

  has_paper_trail on: %i[update], only: %i[deactivated_at]

  attribute :skip_password_validation, :boolean, default: false
  attribute :validate_role, :boolean, default: false

  validates :mobile_number,
            phone: { message: :invalid, allow_international: ALLOW_INTERNATIONAL_PHONE_NUMBER },
            if: -> { mobile_number.present? }

  def resend_account_setup_link
    SearchNotifyMailer.invitation_email(self).deliver_later
  end

  def invitation_expired?
    invited_at <= INVITATION_EXPIRATION_DAYS.days.ago
  end

private

  # Overwrites Devise::Models::Validatable#password_required?
  def password_required?
    return false if skip_password_validation

    super
  end
end
