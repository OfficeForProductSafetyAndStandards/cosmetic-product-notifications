module MyAccount
  class MobileNumberController < SubmitApplicationController
    skip_before_action :create_or_join_responsible_person

    def edit
      @user = current_user
    end

    def update
      @user = current_user
      previously_set = @user.mobile_number.present?

      unless @user.valid_password?(dig_params(:password))
        @user.errors.add(:password, "Password is incorrect")
        return render :edit
      end

      @user.mobile_number = dig_params(:mobile_number)
      @user.mobile_number_verified = false
      @user.enable_sms_authentication

      if @user.save
        redirect_to my_account_path, confirmation: "Mobile number #{previously_set ? 'changed' : 'set'} successfully"
      else
        render :edit
      end
    end

  private

    def current_operation
      SecondaryAuthentication::Operations::CHANGE_MOBILE_NUMBER
    end
  end
end
