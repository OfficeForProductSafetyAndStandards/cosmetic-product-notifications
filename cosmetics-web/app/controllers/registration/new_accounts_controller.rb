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
      user = SubmitUser.confirm_by_token(params[:confirmation_token])
      if user.errors.empty?
        sign_in(user)
        redirect_to registration_new_account_security_path
      end
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
