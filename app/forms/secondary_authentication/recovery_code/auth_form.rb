module SecondaryAuthentication
  class RecoveryCode
    class AuthForm < Form
      RECOVERY_CODE_LENGTH = 8
      INTEGER_REGEX = /\A\d+\z/
      WHITESPACE_REGEX = /[[:space:]]/

      attribute :recovery_code
      attribute :user_id

      validates_presence_of :recovery_code
      validates :recovery_code,
                format: { with: INTEGER_REGEX, message: :numericality },
                allow_blank: true
      validates :recovery_code,
                length: {
                  maximum: RECOVERY_CODE_LENGTH,
                  minimum: RECOVERY_CODE_LENGTH,
                },
                allow_blank: true,
                if: -> { INTEGER_REGEX.match?(recovery_code) }
      validate :correct_recovery_code_validation

      delegate :last_recovery_code_at, to: :secondary_authentication

      def recovery_code=(code)
        super(code.to_s.gsub(WHITESPACE_REGEX, ""))
      end

      def user
        @user ||= User.find(user_id)
      end

    private

      def secondary_authentication
        @secondary_authentication ||= RecoveryCode.new(user)
      end

      def correct_recovery_code_validation
        return if errors.present?

        return errors.add(:recovery_code, :used) if secondary_authentication.used_recovery_code?(recovery_code)

        unless secondary_authentication.valid_recovery_code?(recovery_code)
          errors.add(:recovery_code, :incorrect)
        end
      end
    end
  end
end
