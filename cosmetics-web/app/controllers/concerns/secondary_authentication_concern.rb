# By default is using 'secondary_authentication' operation.
# To protect some actions with custom `secondary_authentication`,
# please override `user_id_for_secondary_authentication` and `current_operation` methods
# in such controller
#
# Only one action in controller can be protected by secondary authentication.
module SecondaryAuthenticationConcern
  extend ActiveSupport::Concern

  def require_secondary_authentication(redirect_to: request.fullpath)
    user = secondary_authentication_user
    return unless user && Rails.configuration.secondary_authentication_enabled

    if !user.account_security_completed?
      redirect_to(registration_new_account_security_path)
    elsif !secondary_authentication_present_in_session? || user.mobile_number_pending_verification?
      session[:secondary_authentication_redirect_to] = redirect_to
      session[:secondary_authentication_user_id] = user_id_for_secondary_authentication
      session[:secondary_authentication_notice] = notice
      session[:secondary_authentication_confirmation] = confirmation

      if secondary_authentication_with_sms? || user.mobile_number_pending_verification?
        session[:secondary_authentication_method] = "sms"
        auth = SecondaryAuthentication::DirectOtp.new(user)
        auth.generate_and_send_code(current_operation)
        redirect_to new_secondary_authentication_sms_path
      elsif user_needs_to_choose_secondary_authentication_method?
        redirect_to new_secondary_authentication_method_path
      else
        session[:secondary_authentication_method] = "app"
        redirect_to new_secondary_authentication_app_path
      end
    end
  end

  # Use as `before_filter` in application_controller controller
  def ensure_secondary_authentication
    session[:last_secondary_authentication_performed_at] = {}
  end

  # returns true if 2 FA not needed
  def secondary_authentication_present_in_session?
    return false if get_secondary_authentication_time.nil?

    last_otp_time = get_secondary_authentication_time
    (last_otp_time + SecondaryAuthentication::Operations::TIMEOUTS[current_operation].seconds) > Time.zone.now
  end

  # can be overrided for actions which require
  # custom secondary authentication flow
  def user_id_for_secondary_authentication
    current_user&.id
  end

  # can be overrided for actions which require
  # custom secondary authentication flow
  def current_operation
    SecondaryAuthentication::Operations::DEFAULT
  end

  def set_secondary_authentication_cookie(timestamp)
    user_id = (session[:secondary_authentication_user_id] || user_id_for_secondary_authentication)
    return if user_id.blank?

    cookies.signed["two-factor-#{user_id}"] = { value: timestamp, expiry: 0 }
  end

  def get_secondary_authentication_time
    return if cookies.signed["two-factor-#{user_id_for_secondary_authentication}"].nil?

    timestamp = cookies.signed["two-factor-#{user_id_for_secondary_authentication}"].to_i
    Time.zone.at(timestamp)
  end

  def secondary_authentication_user
    @secondary_authentication_user ||= User.find_by(
      id: session[:secondary_authentication_user_id] || user_id_for_secondary_authentication,
    )
  end

  def user_needs_to_choose_secondary_authentication_method?
    return false unless secondary_authentication_user

    session[:secondary_authentication_method].blank? &&
      secondary_authentication_user.secondary_authentication_methods.size > 1
  end

  def secondary_authentication_with_sms?
    session[:secondary_authentication_method] == "sms" ||
      secondary_authentication_user&.secondary_authentication_methods == %w[sms]
  end

  def secondary_authentication_with_app?
    session[:secondary_authentication_method] == "app" ||
      secondary_authentication_user&.secondary_authentication_methods == %w[app]
  end
end
