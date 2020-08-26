class MyAccountMobileNumberController < ApplicationController
  def show
    @user = current_user
    render "my_account/mobile_number"
  end

  def update
    @user = current_user

    unless @user.valid_password?(dig_params(:password))
      @user.errors.add(:password, "Password is incorrect")
      return render "my_account/mobile_number"
    end

    @user.mobile_number = dig_params(:mobile_number)
    @user.mobile_number_verified = false

    if @user.save
      redirect_to my_account_path, notice: "Mobile number changed successfully"
    else
      render "my_account/mobile_number"
    end
  end

  private

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
    SecondaryAuthentication::CHANGE_MOBILE_NUMBER
  end
end
