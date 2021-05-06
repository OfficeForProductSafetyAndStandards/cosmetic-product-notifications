module MyAccount
  class MobileNumberController < SubmitApplicationController
    skip_before_action :create_or_join_responsible_person

    def edit
      @user = current_user
      @form = MobileNumberForm.new(mobile_number: @user.mobile_number, user: @user)
    end

    def update
      @user = current_user
      previously_set = @user.mobile_number.present?

      if form.valid?
        @user.update!(mobile_number: form.mobile_number)
        redirect_to my_account_path, confirmation: "Mobile number #{previously_set ? 'changed' : 'set'} successfully"
      else
        render :edit
      end
    end

  private

    def current_operation
      SecondaryAuthentication::Operations::CHANGE_MOBILE_NUMBER
    end

    def form
      @form ||= MobileNumberForm.new(form_params.merge(user: current_user))
    end

    def form_params
      params.require(:mobile_number_form).permit(:mobile_number, :password)
    end
  end
end
