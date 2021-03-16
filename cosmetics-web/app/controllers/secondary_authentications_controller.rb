# Dont inherit from authentication controller
class SecondaryAuthenticationsController < ApplicationController
  skip_before_action :authenticate_user!,
                     :require_secondary_authentication,
                     :authorize_user!,
                     :set_cache_headers

  def new
    user_id = session[:secondary_authentication_user_id]
    return render("errors/forbidden", status: :forbidden) unless user_id

    if user_needs_to_choose_secondary_authentication_method?
      redirect_to new_secondary_authentication_method_path
    elsif secondary_authentication_with_sms?
      @secondary_authentication_form = SecondaryAuthenticationWithSmsForm.new(user_id: user_id)
      @secondary_authentication_form.secondary_authentication.generate_and_send_code(current_operation)
      render :sms
    elsif secondary_authentication_with_app?
      @secondary_authentication_form = SecondaryAuthenticationWithAppForm.new(user_id: user_id)
      render :app
    end
  end

  def create
    if secondary_authentication_with_sms?
      @secondary_authentication_form = sms_form
      if @secondary_authentication_form.valid?
        handle_successful_authentication do
          @secondary_authentication_form.try_to_verify_user_mobile_number
        end
      else
        try_to_resend_sms_code
        @secondary_authentication_form.otp_code = nil
        render :sms
      end
    elsif secondary_authentication_with_app?
      @secondary_authentication_form = app_form
      if @secondary_authentication_form.valid?
        handle_successful_authentication do
          secondary_authentication_user.update!(
            last_totp_at: @secondary_authentication_form.last_totp_at,
          )
        end
      else
        render :app
      end
    end
  end

private

  def handle_successful_authentication
    set_secondary_authentication_cookie(Time.zone.now.to_i)
    yield
    session[:secondary_authentication_user_id] = nil
    session[:secondary_authentication_method] = nil
    redirect_to_saved_path
  end

  def sms_authentication
    sms_form&.secondary_authentication
  end

  def redirect_to_saved_path
    if session[:secondary_authentication_redirect_to]
      redirect_to session.delete(:secondary_authentication_redirect_to), notice: session.delete(:secondary_authentication_notice), confirmation: session.delete(:secondary_authentication_confirmation)
    else
      redirect_to root_path
    end
  end

  def try_to_resend_sms_code
    if sms_authentication.otp_expired? && !sms_authentication.otp_locked?
      sms_authentication.generate_and_send_code(sms_authentication.operation)
    end
  end

  def sms_form
    @sms_form ||= SecondaryAuthenticationWithSmsForm.new(secondary_authentication_params)
  end

  def app_form
    @app_form ||= SecondaryAuthenticationWithAppForm.new(secondary_authentication_params)
  end

  def secondary_authentication_params
    params.require(:secondary_authentication_form).permit(:otp_code, :user_id)
  end
end
