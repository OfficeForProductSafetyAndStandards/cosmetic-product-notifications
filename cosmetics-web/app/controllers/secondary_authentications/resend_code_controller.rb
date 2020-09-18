module SecondaryAuthentications
  class ResendCodeController < ApplicationController
    skip_before_action :authenticate_user!,
                       :require_secondary_authentication,
                       :set_raven_context,
                       :authorize_user!,
                       :has_accepted_declaration,
                       :set_cache_headers
                       :try_to_finish_account_setup

    def new
      @user = find_user
      return render("errors/forbidden", status: :forbidden) unless @user
    end

    def create
      @user = find_user
      return render("errors/forbidden", status: :forbidden) unless @user
      return resend_code unless @user.mobile_number_change_allowed?

      @user.mobile_number = mobile_number_param
      if resend_code_form.valid?
        @user.save!
        resend_code
      else
        @user.errors.merge!(resend_code_form.errors)
        render(:new)
      end
    end

  private

    def resend_code
      # To avoid the user being redirected back to "Resend Security Code" page after successfully introducing
      # the new secondary auth. code, we carry the original redirection path from where 2FA was triggered.
      require_secondary_authentication(redirect_to: session[:secondary_authentication_redirect_to])
    end

    def current_operation
      @user&.secondary_authentication_operation.presence || SecondaryAuthentication::DEFAULT_OPERATION
    end

    def resend_code_form
      @resend_code_form ||= ResendSecondaryAuthenticationCodeForm.new(mobile_number: mobile_number_param, user: @user)
    end

    def user_id_for_secondary_authentication
      current_user&.id || session[:secondary_authentication_user_id]
    end

    def find_user
      current_user || User.find_by(id: session[:secondary_authentication_user_id])
    end

    def mobile_number_param
      params.dig(user_param_key, :mobile_number)
    end
  end
end
