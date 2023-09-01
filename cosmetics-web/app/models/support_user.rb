class SupportUser < User
  include Privileges::SearchConcern

  INVITATION_EXPIRATION_DAYS = 14
  ALLOW_INTERNATIONAL_PHONE_NUMBER = false
  TOTP_ISSUER = "OSU Support Portal".freeze

  attribute :skip_password_validation, :boolean, default: false

  # Only the `opss_general` role is currently used for all
  # support users, but this enum allows the search service
  # privileges to be checked correctly.
  enum role: {
    poison_centre: "poison_centre",
    opss_general: "opss_general",
    opss_enforcement: "opss_enforcement",
    opss_imt: "opss_imt",
    opss_science: "opss_science",
    trading_standards: "trading_standards",
  }

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
    role&.match?(/opss_/)
  end

  def reset_secondary_authentication!
    update(mobile_number: nil,
           mobile_number_verified: false,
           direct_otp: nil,
           direct_otp_sent_at: nil,
           encrypted_totp_secret_key: nil,
           last_totp_at: nil,
           last_recovery_code_at: nil,
           secondary_authentication_methods: nil,
           secondary_authentication_recovery_codes_generated_at: nil,
           secondary_authentication_recovery_codes: [],
           secondary_authentication_recovery_codes_used: [],
           account_security_completed: false)
  end

private

  # Overwrites Devise::Models::Validatable#password_required?
  def password_required?
    return false if skip_password_validation

    super
  end
end
