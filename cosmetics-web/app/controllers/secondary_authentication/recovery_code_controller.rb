module SecondaryAuthentication
  # Don't inherit from authentication controller
  class RecoveryCodeController < ApplicationController
    skip_before_action :authenticate_user!,
                       :require_secondary_authentication,
                       :authorize_user!,
                       :set_cache_headers

    def new
      user_id = session[:secondary_authentication_user_id]

      # Recovery codes are only valid if 2FA has already been set up
      return redirect_to(root_path) unless user_id && (sms_authentication_available? || app_authentication_available?)

      @form = RecoveryCode::AuthForm.new(user_id:)
      @recovery_codes_available = recovery_codes_available?
    end

    def create
      if form.valid?
        set_secondary_authentication_cookie(Time.zone.now.to_i)
        remaining_recovery_codes = form.user.secondary_authentication_recovery_codes
        remaining_recovery_codes.delete(params[:recovery_code])
        form.user.update!(
          last_recovery_code_at: form.last_recovery_code_at,
          secondary_authentication_recovery_codes: remaining_recovery_codes,
          secondary_authentication_recovery_codes_used: form.user.secondary_authentication_recovery_codes_used.push(params[:recovery_code]),
        )
        session[:secondary_authentication_user_id] = nil
        redirect_to secondary_authentication_recovery_code_interstitial_path
      else
        @recovery_codes_available = recovery_codes_available?
        render :new
      end
    end

    def interstitial
      @recovery_codes_used = current_user.secondary_authentication_recovery_codes_used.length
      @recovery_codes_remaining = current_user.secondary_authentication_recovery_codes.length
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

  private

    def form
      @form ||= RecoveryCode::AuthForm.new(secondary_authentication_params)
    end

    def secondary_authentication_params
      params.permit(:recovery_code, :user_id)
    end
  end
end
