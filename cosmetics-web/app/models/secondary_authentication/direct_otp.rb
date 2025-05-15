module SecondaryAuthentication
  class DirectOtp
    include OtpWhitelisting

    OTP_LENGTH = 5
    MAX_ATTEMPTS = Rails.configuration.two_factor_attempts
    MAX_ATTEMPTS_COOLDOWN = 3600 # 1 hour
    OTP_RESEND_SECONDS = 60 # 1 min
    OTP_EXPIRY_SECONDS = 300 # 5 mins
    WHITELISTED_OTP_CODE = Rails.configuration.whitelisted_direct_otp_code

    attr_accessor :user

    def initialize(user)
      @user = user
    end

    def generate_and_send_code(operation)
      generate_code(operation)
      send_secondary_authentication_code
    end

    def otp_resend_allowed?
      user.direct_otp_sent_at && (user.direct_otp_sent_at + OTP_RESEND_SECONDS) < Time.zone.now
    end

    def otp_expired?
      user.direct_otp_sent_at && (user.direct_otp_sent_at + OTP_EXPIRY_SECONDS) < Time.zone.now
    end

    def otp_locked?
      user.second_factor_attempts_locked_at.present? && (user.second_factor_attempts_locked_at + MAX_ATTEMPTS_COOLDOWN.seconds) > Time.zone.now
    end

    def valid_otp?(otp)
      try_to_unlock_secondary_authentication

      user.with_lock do
        increment_attempts_and_try_to_lock
      end
      user.reload.second_factor_attempts_locked_at.nil? && (otp == user.direct_otp || whitelisted_code_valid?(otp))
    end

    def generate_code(operation)
      user.update!(
        second_factor_attempts_count: 0,
        direct_otp: random_base10(OTP_LENGTH),
        direct_otp_sent_at: Time.zone.now,
        secondary_authentication_operation: operation,
      )
    end

    def send_secondary_authentication_code
      SendSecondaryAuthenticationDirectOtpJob.perform_later(user, user.direct_otp)
    end

    def try_to_verify_user_mobile_number
      user.update!(mobile_number_verified: true) unless user.mobile_number_verified?
    end

    def try_to_unlock_secondary_authentication
      if user.second_factor_attempts_locked_at && (user.second_factor_attempts_locked_at + MAX_ATTEMPTS_COOLDOWN.seconds) < Time.zone.now
        user.update!(second_factor_attempts_locked_at: nil)
      end
    end

    def operation
      user.secondary_authentication_operation
    end

    delegate :direct_otp, to: :user

  private

    def random_base10(digits)
      SecureRandom.random_number(10**digits).to_s.rjust(digits, "0")
    end

    def increment_attempts_and_try_to_lock
      user.increment!(:second_factor_attempts_count) unless otp_locked?

      if user.second_factor_attempts_count > MAX_ATTEMPTS
        user.update!(second_factor_attempts_locked_at: Time.zone.now, second_factor_attempts_count: 0)
      end
    end
  end
end
