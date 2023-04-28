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
      if submit_domain?
        redirect_to registration_new_account_security_path
      else
        redirect_to complete_registration_user_path(user, invitation: user.invitation_token)
      end
    elsif !secondary_authentication_present_in_session? || user.mobile_number_pending_verification?
      session[:secondary_authentication_redirect_to] = redirect_to
      session[:secondary_authentication_user_id] = user.id
      session[:secondary_authentication_notice] = notice
      session[:secondary_authentication_confirmation] = confirmation
      if use_sms_authentication?
        redirect_to new_secondary_authentication_sms_path
      elsif use_app_authentication?
        redirect_to new_secondary_authentication_app_path
      else
        redirect_to new_secondary_authentication_method_path
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

    cookies.signed["two-factor-#{user_id}"] = { value: timestamp, secure: Rails.env.production?, httponly: true }
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

  def available_secondary_authentication_methods
    return [] unless secondary_authentication_user

    secondary_authentication_user.secondary_authentication_methods
  end

  def use_sms_authentication?
    return false unless secondary_authentication_user

    available_secondary_authentication_methods == %w[sms] ||
      secondary_authentication_user.mobile_number_pending_verification?
  end

  def use_app_authentication?
    available_secondary_authentication_methods == %w[app]
  end

  def sms_authentication_available?
    available_secondary_authentication_methods.include? "sms"
  end

  def app_authentication_available?
    available_secondary_authentication_methods.include? "app"
  end

  def recovery_codes_available?
    return false unless secondary_authentication_user

    !secondary_authentication_user.secondary_authentication_recovery_codes.empty?
  end
end
