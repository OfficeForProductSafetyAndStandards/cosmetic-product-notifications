module SecondaryAuthentication
  module OtpWhitelisting
    def whitelisted_code_valid?(otp)
      return unless otp_whitelisting_allowed?

      if self.class::WHITELISTED_OTP_CODE.present?
        code = self.class::WHITELISTED_OTP_CODE
        code == otp
      else
        false
      end
    end

    def otp_whitelisting_allowed?
      return true if Rails.env.development?

      uris = JSON(Rails.configuration.vcap_application)["application_uris"]
      return false if uris.blank?

      uris.all? do |uri|
        Rails.application.config.domains_allowing_otp_whitelisting["domains-regexps"].any? do |domain_regexp|
          uri =~ domain_regexp
        end
      end
    rescue StandardError
      false
    end
  end
end
