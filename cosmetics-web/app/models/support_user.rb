class SupportUser < User
  include Privileges::SearchConcern

  INVITATION_EXPIRATION_DAYS = 14
  ALLOW_INTERNATIONAL_PHONE_NUMBER = false
  TOTP_ISSUER = "OSU Support Portal".freeze

  attribute :skip_password_validation, :boolean, default: false

  validates :email,
            email: {
              message: :invalid,
              if: -> { email.present? },
            }

  validates :mobile_number,
            phone: { message: :invalid, allow_international: ALLOW_INTERNATIONAL_PHONE_NUMBER },
            if: -> { mobile_number.present? }

  def resend_account_setup_link
    SupportNotifyMailer.invitation_email(self).deliver_later
  end

  def invitation_expired?
    invited_at <= INVITATION_EXPIRATION_DAYS.days.ago
  end

  def opss?
    has_role?(:opss_general) || has_role?(:opss_enforcement) || has_role?(:opss_imt) || has_role?(:opss_science)
  end

private

  # Overwrites Devise::Models::Validatable#password_required?
  def password_required?
    return false if skip_password_validation

    super
  end
end
