module MyAccount
  class EmailController < SubmitApplicationController
    skip_before_action :create_or_join_responsible_person

    def edit
      @user = current_user
    end

    def update
      @user = current_user

      unless @user.valid_password?(dig_params(:password))
        @user.errors.add(:password, "Password is incorrect")
        return render :edit
      end

      @user.new_email_pending_confirmation!(dig_params(:new_email))
      render "users/check_your_email/show"
    rescue ActiveRecord::RecordInvalid => e
      # We don't want to let the user know when validation failed due to new email being already registered
      if e.message.include? "has already been taken"
        render "users/check_your_email/show"
      else
        render :edit
      end
    end

    def confirm
      User.confirm_new_email!(params[:confirmation_token])
      redirect_to my_account_path, confirmation: "Email changed successfully"
    rescue ArgumentError
      redirect_to my_account_path, alert: "Email can not be changed, confirmation token is incorrect. Please try again."
    end

  private

    def current_operation
      SecondaryAuthentication::Operations::CHANGE_EMAIL_ADDRESS
    end
  end
end
