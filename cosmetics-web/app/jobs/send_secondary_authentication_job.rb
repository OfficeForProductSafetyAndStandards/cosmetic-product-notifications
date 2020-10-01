class SendSecondaryAuthenticationJob < ApplicationJob
  def perform(user, code)
    if user.is_a? SubmitUser
      SendSubmitSMS.otp_code(mobile_number: user.mobile_number, code: code)
      return
    end
    if user.is_a? SearchUser
      SendSearchSMS.otp_code(mobile_number: user.mobile_number, code: code)
      return
    end
    raise "Imposible to find SMS sending class for '#{user.class}'"
  end
end
