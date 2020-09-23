# Dont inherit from authentication controller
class SecondaryAuthenticationsController < ApplicationController
  skip_before_action :authenticate_user!,
                     :require_secondary_authentication,
                     :set_raven_context,
                     :authorize_user!,
                     :has_accepted_declaration,
                     :create_or_join_responsible_person,
                     :set_cache_headers

  def new
    return render("errors/forbidden", status: :forbidden) unless session[:secondary_authentication_user_id]

    @secondary_authentication_form = SecondaryAuthenticationForm.new(user_id: session[:secondary_authentication_user_id])
  end

  def create
    if secondary_authentication_form.valid?
      set_secondary_authentication_cookie(Time.now.utc.to_i)
      secondary_authentication_form.try_to_verify_user_mobile_number
      redirect_to_saved_path
    else
      try_to_resend_code
      secondary_authentication_form.otp_code = nil
      render :new
    end
  end

private

  def secondary_authentication
    @secondary_authentication_form&.secondary_authentication
  end

  def redirect_to_saved_path
    session[:secondary_authentication_user_id] = nil
    if session[:secondary_authentication_redirect_to]
      redirect_to session.delete(:secondary_authentication_redirect_to), notice: session.delete(:secondary_authentication_notice)
    else
      redirect_to root_path
    end
  end

  def try_to_resend_code
    if secondary_authentication.otp_expired? && !secondary_authentication.otp_locked?
      secondary_authentication.generate_and_send_code(secondary_authentication.operation)
    end
  end

  def secondary_authentication_form
    @secondary_authentication_form ||= SecondaryAuthenticationForm.new(secondary_authentication_params)
  end

  def secondary_authentication_params
    params.require(:secondary_authentication_form).permit(:otp_code, :user_id)
  end
end
