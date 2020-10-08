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

    ActiveRecord::Base.transaction do
      @user.save!
      user.send_new_email_confirmation_email
      render "users/check_your_email/show"
    end
  rescue
    render "my_account/email"
  end

  def confirm
    User.new_email!(params[:confirmation_token])
    redirect_to my_account_path, confirmation: "Email changed successfully"
  rescue ArgumentError
    redirect_to my_account_path, alert: "Email can not be changed, confirmation token is incorrect. Please try again."
  end

private

  def current_operation
    SecondaryAuthentication::CHANGE_EMAIL_ADDRESS
  end
end
