module SecondaryAuthentication
  # Dont inherit from authentication controller
  class AppController < ApplicationController
    skip_before_action :authenticate_user!,
                       :require_secondary_authentication,
                       :authorize_user!,
                       :set_cache_headers

    def new
      user_id = session[:secondary_authentication_user_id]
      return redirect_to(root_path) unless user_id && app_authentication_available?

      @form = App::AuthForm.new(user_id:)
    end

    def create
      if form.valid?
        set_secondary_authentication_cookie(Time.zone.now.to_i)
        form.user.update!(last_totp_at: form.last_totp_at)
        session[:secondary_authentication_user_id] = nil
        redirect_to_saved_path
      else
        render :new
      end
    end

  private

    def form
      @form ||= App::AuthForm.new(secondary_authentication_params)
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
