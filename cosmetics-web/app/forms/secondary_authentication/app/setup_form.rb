module SecondaryAuthentication
  module App
    class SetupForm < Form
      include UserPasswordCheckFormValidation

      attribute :app_authentication_code
      attribute :secret_key
      attribute :user

      validates :app_authentication_code, presence: true
      validate :app_authentication_code, :validate_app_authentication_code

      delegate :qr_code, :last_totp_at, to: :secondary_authentication

      # Generates a new key only if key is not coming from the form submission.
      # Keeping the same key between failed form submissions is important as
      # allows to keep the same QR code between attempts.
      # If not the user would need to re-add the QR code into their authenticator
      # app with each failed submission attempt.
      def secret_key
        @secret_key ||= (super || SecondaryAuthentication::TimeOtp.generate_secret_key)
      end

      def decorated_secret_key
        # Groups of 4 characters followed by a space
        secret_key.gsub(/(.{4})/, '\1 ').strip
      end

    private

      def secondary_authentication
        @secondary_authentication ||= SecondaryAuthentication::TimeOtp.new(user, secret_key)
      end

      def validate_app_authentication_code
        return if app_authentication_code.blank?

        unless secondary_authentication.valid_otp?(app_authentication_code)
          errors.add(:app_authentication_code, :invalid)
        end
      end
    end
  end
end
