class SendSecondaryAuthenticationDirectOtpJob < ApplicationJob
  def perform(user, code)
    if user.is_a? SubmitUser
      SendSubmitSms.otp_code(mobile_number: user.mobile_number, code:)
      return
    end
    if user.is_a? SearchUser
      SendSearchSms.otp_code(mobile_number: user.mobile_number, code:)
      return
    end
    if user.is_a? SupportUser
      SendSupportSms.otp_code(mobile_number: user.mobile_number, code:)
      return
    end
    raise "SMS sending class for '#{user.class}' not found"
  end
end
