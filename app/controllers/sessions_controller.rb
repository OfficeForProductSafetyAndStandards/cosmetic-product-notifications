class SessionsController < ApplicationController
  def new; end

  def signin
    begin
      user = params[:user]
      cookies.permanent[:keycloak_token] = Keycloak::Client.get_token user[:email], user[:password]
      flash[:notice] = "Signed in successfully." if Keycloak::Client.user_signed_in?
      redirect_to root_path
    rescue RestClient::ExceptionWithResponse => error
      is_unauthorised = error.is_a? RestClient::Unauthorized
      flash[:alert] = is_unauthorised ? "Invalid email or password." : JSON(error.response)["error_description"]
      redirect_to sessions_new_path
    end
  end

  def logout
    flash[:notice] = "Signed out successfully." if Keycloak::Client.logout
    redirect_to root_path
  end

  def forgot_password; end

  def reset_password
    begin
      user = params[:user]
      Keycloak::Internal.forgot_password user[:email], root_path
      flash[:notice] = "A password reset link has been sent to your email address."
      redirect_to root_path
    rescue
      flash[:alert] = "Failed to send reset email."
      redirect_to sessions_forgot_password_path
    end
  end
end
