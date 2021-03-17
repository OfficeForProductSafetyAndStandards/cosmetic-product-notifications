class SecondaryAuthenticationWithAppForm
  include ActiveModel::Model
  include ActiveModel::Attributes

  AUTHENTICATION_APP_CODE_LENGTH = 6
  INTEGER_REGEX = /\A\d+\z/.freeze

  attribute :otp_code
  attribute :user_id

  validates_presence_of :otp_code
  validates :otp_code,
            format: { with: INTEGER_REGEX, message: :numericality },
            allow_blank: true
  validates :otp_code,
            length: {
              maximum: AUTHENTICATION_APP_CODE_LENGTH,
              minimum: AUTHENTICATION_APP_CODE_LENGTH,
            },
            allow_blank: true,
            if: -> { INTEGER_REGEX.match?(otp_code) }
  validate :correct_otp_validation

  def otp_code=(code)
    super(code.to_s.strip)
  end

  # As a new TOTP code is generated every 30secs, we wanto to verify the given code
  # as soon as possible and memoize the result. Without memoization, a further check
  # could cause a code that originally returned a valid verification timestamp to fail
  # on the following call.
  def last_totp_at
    return if otp_code.blank?

    @last_totp_at ||= totp.verify(otp_code.strip, drift_behind: 15)
  end

  def back_link?
    user && user.secondary_authentication_methods.size > 1
  end

  def user
    @user ||= User.find(user_id)
  end

private

  def secondary_authentication
    @secondary_authentication ||= SecondaryAuthentication::DirectOtp.new(user)
  end

  # Brought from Account Sec form
  def totp
    @totp ||= ROTP::TOTP.new(user.totp_secret_key)
  end

  def correct_otp_validation
    return if errors.present?

    errors.add(:otp_code, :incorrect) if last_totp_at.blank?
  end
end
