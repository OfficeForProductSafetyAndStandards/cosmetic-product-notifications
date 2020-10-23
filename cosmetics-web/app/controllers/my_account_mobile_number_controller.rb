class MyAccountMobileNumberController < SubmitApplicationController
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
      redirect_to my_account_path, confirmation: "Mobile number changed successfully"
    else
      render "my_account/mobile_number"
    end
  end

private

  def current_operation
    SecondaryAuthentication::CHANGE_MOBILE_NUMBER
  end
end
