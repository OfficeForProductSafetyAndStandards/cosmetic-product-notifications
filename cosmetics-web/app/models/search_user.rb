class SearchUser < User
  include Privileges::SearchConcern

  INVITATION_EXPIRATION_DAYS = 14
  ALLOW_INTERNATIONAL_PHONE_NUMBER = false
  TOTP_ISSUER = "Search Cosmetics".freeze

  has_paper_trail on: %i[update], only: %i[role]

  attribute :skip_password_validation, :boolean, default: false
  attribute :validate_role, :boolean, default: false

  enum role: {
    poison_centre: "poison_centre",
    opss_general: "opss_general",
    opss_enforcement: "opss_enforcement",
    opss_imt: "opss_imt",
    opss_science: "opss_science",
    trading_standards: "trading_standards",
  }

  validates :mobile_number,
            phone: { message: :invalid, allow_international: ALLOW_INTERNATIONAL_PHONE_NUMBER },
            if: -> { mobile_number.present? }
  validates :role, inclusion: { in: roles.keys }, if: -> { validate_role }

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
