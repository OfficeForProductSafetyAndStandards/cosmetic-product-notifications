module Shared
  module Web
    class SessionsController < Shared::Web::ApplicationController
      skip_before_action :authenticate_user!

      def new
        redirect_to keycloak_login_url(request.original_fullpath)
      end

      def signin
        request_and_store_token(auth_code, params[:request_path])
        flash[:notice] = "Signed in successfully." if Shared::Web::KeycloakClient.instance.user_signed_in?
        redirect_path = main_app.root_path
        redirect_path = params[:request_path] if is_relative(params[:request_path])
        redirect_to redirect_path
      rescue RestClient::ExceptionWithResponse => error
        redirect_to keycloak_login_url(params[:request_path]), alert: signin_error_message(error)
      end

      def logout
        flash[:notice] = "Signed out successfully." if Shared::Web::KeycloakClient.instance.logout
        redirect_to main_app.root_path
      end

    private

      def request_and_store_token(auth_code, redirect_url)
        cookies.permanent[cookie_name] = {
          value: Shared::Web::KeycloakClient.instance.exchange_code_for_token(auth_code, get_session_url_with_redirect(redirect_url)),
          httponly: true
        }
      end

      def signin_error_message(error)
        error.is_a?(RestClient::Unauthorized) ? "Invalid email or password." : JSON(error.response)["error_description"]
      end

      def auth_code
        params.require(:code)
      end
    end
  end
end
