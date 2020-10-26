# By default is using 'secondary_authentication' operation.
# To protect some actions with custom `secondary_authentication`,
# please override `user_id_for_secondary_authentication` and `current_operation` methods
# in such controller
#
# Only one action in controller can be protected by secondary authentication.
module SecondaryAuthenticationConcern
  extend ActiveSupport::Concern

  def require_secondary_authentication(redirect_to: request.fullpath)
    return unless Rails.configuration.secondary_authentication_enabled

    if user && (!user.mobile_number_verified || !secondary_authentication_present?)
      session[:secondary_authentication_redirect_to] = redirect_to
      session[:secondary_authentication_user_id] = user_id_for_secondary_authentication
      session[:secondary_authentication_notice] = notice
      session[:secondary_authentication_confirmation] = confirmation
      auth = SecondaryAuthentication.new(user)
      auth.generate_and_send_code(current_operation)
      redirect_to new_secondary_authentication_path
    end
  end

  # Use as `before_filter` in application_controller controller
  def ensure_secondary_authentication
    session[:last_secondary_authentication_performed_at] = {}
  end

  # returns true if 2 FA not needed
  def secondary_authentication_present?
    return false if get_secondary_authentication_time.nil?

    last_otp_time = get_secondary_authentication_time
    (last_otp_time + SecondaryAuthentication::TIMEOUTS[current_operation].seconds) > Time.zone.now
  end

  # can be overrided for actions which require
  # custom secondary authentication flow
  def user_id_for_secondary_authentication
    current_user&.id
  end

  # can be overrided for actions which require
  # custom secondary authentication flow
  def current_operation
    SecondaryAuthentication::DEFAULT_OPERATION
  end

  def set_secondary_authentication_cookie(timestamp)
    cookies.signed["two-factor-#{session[:secondary_authentication_user_id]}"] = {
      value: timestamp,
      expiry: 0,
    }
  end

  def get_secondary_authentication_time
    return if cookies.signed["two-factor-#{user_id_for_secondary_authentication}"].nil?

    timestamp = cookies.signed["two-factor-#{user_id_for_secondary_authentication}"].to_i
    Time.zone.at(timestamp)
  end

  def user
    User.find_by(id: user_id_for_secondary_authentication)
  end
end
