class SessionsController < ApplicationController
  def new; end

  def signin
    request_and_store_token(params[:user])
    flash[:notice] = "Signed in successfully." if KeycloakClient.instance.user_signed_in?
    redirect_to root_path
  rescue RestClient::ExceptionWithResponse => error
    redirect_to sessions_new_path, alert: signin_error_message(error)
  end

  def logout
    flash[:notice] = "Signed out successfully." if KeycloakClient.instance.logout
    redirect_to root_path
  end

  def forgot_password; end

  def reset_password
    send_password_reset_email(params[:user])
    redirect_to root_path, notice: "A password reset link has been sent to your email address."
  rescue RuntimeError
    redirect_to sessions_forgot_password_path, alert: "Failed to send reset email."
  end

private

  def request_and_store_token(user)
    cookies.permanent[:keycloak_token] = KeycloakClient.instance.token_for_user(user)
  end

  def send_password_reset_email(user)
    KeycloakClient.instance.send_password_reset_email(user, root_path)
  end

  def signin_error_message(error)
    error.is_a?(RestClient::Unauthorized) ? "Invalid email or password." : JSON(error.response)["error_description"]
  end
end
