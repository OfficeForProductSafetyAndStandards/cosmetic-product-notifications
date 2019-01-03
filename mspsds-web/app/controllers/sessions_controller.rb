class SessionsController < ApplicationController
  include LoginHelper

  skip_before_action :authenticate_user!

  def new
    redirect_to keycloak_login_url(request.original_url)
  end

  def signin
    request_and_store_token(auth_code, params[:request_url])
    flash[:notice] = "Signed in successfully." if KeycloakClient.instance.user_signed_in?
    redirect_url = params[:request_url] || root_path
    redirect_to redirect_url
  rescue RestClient::ExceptionWithResponse => error
    redirect_to keycloak_login_url(params[:request_url]), alert: signin_error_message(error)
  end

  def logout
    flash[:notice] = "Signed out successfully." if KeycloakClient.instance.logout
    redirect_to root_path
  end

private

  def request_and_store_token(auth_code, redirect_url)
    cookies.permanent[:keycloak_token] = {
      value: KeycloakClient.instance.exchange_code_for_token(auth_code, get_session_url_with_redirect(redirect_url)),
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
