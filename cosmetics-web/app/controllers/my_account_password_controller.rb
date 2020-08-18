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
    @user.password_confirmation = dig_params(:password_confirmation)

    if @user.save
      sign_in(@user, bypass: true)
      redirect_to my_account_path, notice: "Password changed successfully"
    else
      render "my_account/password"
    end
  end

  private

  def dig_params(param)
    params.dig(user_param_key, param)
  end

  def user_class
    if params.key?("search_user")
      return SearchUser
    elsif params.key?("submit_user")
      return SubmitUser
    end

    raise ArgumentError
  end

  def user_param_key
    user_class.name.underscore.to_sym
  end

  def current_operation
    SecondaryAuthentication::CHANGE_PASSWORD
  end
end
