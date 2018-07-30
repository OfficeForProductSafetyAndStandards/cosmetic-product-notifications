class SessionsController < ApplicationController
  def new; end

  def signin
    request_and_store_token(params[:user])
    flash[:notice] = "Signed in successfully." if Keycloak::Client.user_signed_in?
    redirect_to root_path
  rescue RestClient::ExceptionWithResponse => error
    flash[:alert] = signin_error_message(error)
    redirect_to sessions_new_path
  end

  def logout
    flash[:notice] = "Signed out successfully." if Keycloak::Client.logout
    redirect_to root_path
  end

  def forgot_password; end

  def reset_password
    send_password_reset_email(params[:user])
    flash[:notice] = "A password reset link has been sent to your email address."
    redirect_to root_path
  rescue RuntimeError
    flash[:alert] = "Failed to send reset email."
    redirect_to sessions_forgot_password_path
  end

  private

  def request_and_store_token(user)
    cookies.permanent[:keycloak_token] = Keycloak::Client.get_token user[:email], user[:password]
  end

  def send_password_reset_email(user)
    Keycloak::Internal.forgot_password user[:email], root_path
  end

  def signin_error_message(error)
    error.is_a? RestClient::Unauthorized ? "Invalid email or password." : JSON(error.response)["error_description"]
  end
end
