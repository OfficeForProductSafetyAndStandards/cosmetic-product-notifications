module SecondaryAuthentication
  class AppForm
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

    delegate :last_totp_at, to: :secondary_authentication

    def otp_code=(code)
      super(code.to_s.strip)
    end

    def back_link?
      user && user.secondary_authentication_methods.size > 1
    end

    def user
      @user ||= User.find(user_id)
    end

  private

    def secondary_authentication
      @secondary_authentication ||= TimeOtp.new(user)
    end

    def correct_otp_validation
      return if errors.present?

      unless secondary_authentication.valid_otp?(otp_code)
        errors.add(:otp_code, :incorrect)
      end
    end
  end
end
