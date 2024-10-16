module SecondaryAuthentication
  class RecoveryCode
    attr_accessor :user, :last_recovery_code_at

    def initialize(user)
      @user = user
    end

    def valid_recovery_code?(recovery_code)
      return false if recovery_code.blank?

      if user.secondary_authentication_recovery_codes.include?(recovery_code)
        @last_recovery_code_at = Time.zone.now
        true
      else
        false
      end
    end

    def used_recovery_code?(recovery_code)
      return false if recovery_code.blank?

      user.secondary_authentication_recovery_codes_used.include?(recovery_code)
    end
  end
end
