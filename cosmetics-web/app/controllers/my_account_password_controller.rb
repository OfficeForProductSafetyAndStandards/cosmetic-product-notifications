class MyAccountPasswordController < ApplicationController
  def show
    @user = current_user
    render "my_account/password"
  end

  def update
    @user = current_user

    unless @user.valid_password?(dig_params(:old_password))
      @user.errors.add(:old_password, "Old password is incorrect")
      return render "my_account/password"
    end

    @user.password = dig_params(:password)

    if @user.save
      bypass_sign_in(@user)
      redirect_to my_account_path, confirmation: "Password changed successfully"
    else
      render "my_account/password"
    end
  end

private

  def current_operation
    SecondaryAuthentication::Operations::CHANGE_PASSWORD
  end
end
