module Registration
  class NewAccountsController < ApplicationController
    skip_before_action :authorize_user!
    skip_before_action :authenticate_user!
    skip_before_action :require_secondary_authentication

    def new
      @new_account_form = NewAccountForm.new
    end

    def create
      if new_account_form.save
        render 'users/check_your_email/show'
      else
        # user might be already in database:
          # confirmed
          # unconfirmed
        render :new
      end
    end

    def confirm
      return render 'signed_as_another_user' if current_submit_user

      @new_user = SubmitUser.confirm_by_token(params[:confirmation_token])
      if @new_user.errors.empty?
        sign_in(@new_user)
        redirect_to registration_new_account_security_path
      end
    end

    def sign_out_before_confirming_email
      sign_out
      redirect_to registration_confirm_submit_user_path(confirmation_token: params[:confirmation_token])
    end

  protected

    def after_inactive_sign_up_path_for(_resource)
      check_your_email_path
    end

  private

    def new_account_form
      @new_account_form ||= NewAccountForm.new(new_account_form_params)
    end

    def new_account_form_params
      params.require(:registration_new_account_form).permit(:full_name, :email)
    end
  end
end
