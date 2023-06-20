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
    opss_science: "opss_science",
    trading_standards: "trading_standards",
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

private

  # Overwrites Devise::Models::Validatable#password_required?
  def password_required?
    return false if skip_password_validation

    super
  end
end
