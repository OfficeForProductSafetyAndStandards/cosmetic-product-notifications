module SecondaryAuthentication
  # Dont inherit from authentication controller
  class AppController < ApplicationController
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
        @form = AppForm.new(user_id: user_id)
      end
    end

    def create
      if form.valid?
        set_secondary_authentication_cookie(Time.zone.now.to_i)
        form.user.update!(last_totp_at: form.last_totp_at)
        session[:secondary_authentication_user_id] = nil
        session[:secondary_authentication_method] = nil
        redirect_to_saved_path
      else
        render :new
      end
    end

  private

    def form
      @form ||= AppForm.new(secondary_authentication_params)
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
