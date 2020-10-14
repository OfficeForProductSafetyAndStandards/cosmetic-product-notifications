class SendSecondaryAuthenticationJob < ApplicationJob
  def perform(user, code)
    SendSMS.otp_code(mobile_number: user.mobile_number, code: code)
  end
end
