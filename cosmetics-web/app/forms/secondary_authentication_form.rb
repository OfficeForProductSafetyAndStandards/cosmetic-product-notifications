class SecondaryAuthenticationForm
  include ActiveModel::Model
  include ActiveModel::Attributes

  INTEGER_REGEX = /\A\d+\z/.freeze

  attribute :otp_code
  attribute :user_id

  validates_presence_of :otp_code, message: I18n.t(".otp_code.blank")
  validates :otp_code,
            format: { with: INTEGER_REGEX, message: I18n.t(".otp_code.numericality") },
            allow_blank: true
  validates :otp_code,
            length: {
              maximum: SecondaryAuthentication::OTP_LENGTH,
              too_long: I18n.t(".otp_code.too_long"),
              minimum: SecondaryAuthentication::OTP_LENGTH,
              too_short: I18n.t(".otp_code.too_short")
            },
            allow_blank: true,
            if: -> { INTEGER_REGEX.match?(otp_code) }
  validate :correct_otp_validation
  validate :otp_attempts_validation
  validate :otp_expiry_validation

  delegate :try_to_verify_user_mobile_number, :operation, to: :secondary_authentication

  def otp_code=(code)
    super(code.to_s.strip)
  end

  def correct_otp_validation
    return if errors.present?

    unless secondary_authentication.valid_otp? otp_code
      errors.add(:otp_code, I18n.t(".otp_code.incorrect"))
    end
  end

  def otp_attempts_validation
    return if errors.present?

    if secondary_authentication.otp_locked?
      errors.add(:otp_code, I18n.t(".otp_code.incorrect"))
    end
  end

  def otp_expiry_validation
    return if errors.present?

    if secondary_authentication.otp_expired?
      errors.add(:otp_code, I18n.t(".otp_code.expired"))
    end
  end

  def secondary_authentication
    @secondary_authentication ||= SecondaryAuthentication.new(User.find(user_id))
  end
end
