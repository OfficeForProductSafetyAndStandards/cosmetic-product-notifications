class MyAccountEmailController < ApplicationController
  def show
    @user = current_user
    render "my_account/email"
  end

  def update
    @user = current_user

    unless @user.valid_password?(dig_params(:password))
      @user.errors.add(:password, "Password is incorrect")
      return render "my_account/email"
    end

    @user.new_email = dig_params(:new_email)

    if @user.save
      user.send_new_email_confirmation_email
      redirect_to my_account_path, notice: "Confirmation email sent. Please follow instructions from email"
    else
      render "my_account/email"
    end
  end

  def confirm
    User.new_email!(params[:confirmation_token])
    redirect_to my_account_path, notice: "Email changed successfully"
  rescue ArgumentError
    redirect_to my_account_path, notice: "Email can not be changed, confirmation token is incorrect. Please try again."
  end

  private

  def current_operation
    SecondaryAuthentication::CHANGE_EMAIL_ADDRESS
  end
end
