module SecondaryAuthentication
  module Sms
    class AuthForm < Form
      INTEGER_REGEX = /\A\d+\z/.freeze

      attribute :otp_code
      attribute :user_id

      validates_presence_of :otp_code
      validates :otp_code,
                format: { with: INTEGER_REGEX, message: :numericality },
                allow_blank: true
      validates :otp_code,
                length: {
                  maximum: DirectOtp::OTP_LENGTH,
                  minimum: DirectOtp::OTP_LENGTH,
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
          errors.add(:otp_code, :incorrect)
        end
      end

      def otp_attempts_validation
        return if errors.present?

        if secondary_authentication.otp_locked?
          errors.add(:otp_code, :incorrect)
        end
      end

      def otp_expiry_validation
        return if errors.present?

        if secondary_authentication.otp_expired?
          errors.add(:otp_code, :expired)
        end
      end

      def secondary_authentication
        @secondary_authentication ||= DirectOtp.new(user)
      end

      def user
        @user ||= User.find(user_id)
      end
    end
  end
end
