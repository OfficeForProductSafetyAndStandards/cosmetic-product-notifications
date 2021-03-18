module SecondaryAuthentication
  # Dont inherit from authentication controller
  class SmsController < ApplicationController
    skip_before_action :authenticate_user!,
                       :require_secondary_authentication,
                       :authorize_user!,
                       :set_cache_headers

    def new
      user_id = session[:secondary_authentication_user_id]
      return render("errors/forbidden", status: :forbidden) unless user_id

      if user_needs_to_choose_secondary_authentication_method?
        redirect_to new_secondary_authentication_method_path
      else
        @form = SmsForm.new(user_id: user_id)
        @form.secondary_authentication.generate_and_send_code(current_operation)
      end
    end

    def create
      if form.valid?
        set_secondary_authentication_cookie(Time.zone.now.to_i)
        form.try_to_verify_user_mobile_number
        session[:secondary_authentication_user_id] = nil
        session[:secondary_authentication_method] = nil
        redirect_to_saved_path
      else
        if sms_authentication.otp_expired? && !sms_authentication.otp_locked?
          sms_authentication.generate_and_send_code(sms_authentication.operation)
        end
        render :new
      end
    end

  private

    def form
      @form ||= SmsForm.new(secondary_authentication_params)
    end

    def sms_authentication
      form&.secondary_authentication
    end

    def secondary_authentication_params
      params.permit(:otp_code, :user_id)
    end

    def redirect_to_saved_path
      if session[:secondary_authentication_redirect_to]
        redirect_to session.delete(:secondary_authentication_redirect_to),
                    notice: session.delete(:secondary_authentication_notice),
                    confirmation: session.delete(:secondary_authentication_confirmation)
      else
        redirect_to root_path
      end
    end
  end
end
