module SecondaryAuthentication
  module App
    class SetupController < ApplicationController
      def new
        @user = current_user
        return redirect_to(root_path) unless @user

        @form = SetupForm.new(user: @user)
      end

      def create
        @user = current_user
        return render("errors/forbidden", status: :forbidden) unless @user

        if form.valid?
          @user.update!(
            last_totp_at: form.secondary_authentication.last_totp_at,
            totp_secret_key: form.secret_key,
            secondary_authentication_methods: @user.secondary_authentication_methods.push("app").uniq,
          )
          redirect_to my_account_path, confirmation: "Authenticator app set successfully"
        else
          render(:new)
        end
      end

    private

      def current_operation
        SecondaryAuthentication::Operations::SETUP_APP_AUTHENTICATION
      end

      def form
        @form ||= SetupForm.new(form_params.merge(user: @user))
      end

      def form_params
        params.require(:secondary_authentication_app_setup_form)
              .permit(:secret_key, :app_authentication_code, :password)
      end
    end
  end
end
