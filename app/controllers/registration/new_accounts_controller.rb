module Registration
  class NewAccountsController < SubmitApplicationController
    before_action :redirect_if_create_an_account_disabled, only: %i[new create confirm]

    skip_before_action :authorize_user!
    skip_before_action :authenticate_user!
    skip_before_action :require_secondary_authentication

    def new
      sign_out
      @new_account_form = NewAccountForm.new
    end

    def create
      if new_account_form.save
        render "users/check_your_email/show", locals: { email: new_account_form.email }
      else
        render :new
      end
    end

    def confirm
      return render "signed_as_another_user" if current_submit_user

      token = params[:confirmation_token]
      return render "confirmation_token_is_invalid" if token.blank?

      @new_user = SubmitUser.confirm_by_token(token)
      return render "confirmation_token_is_invalid" unless @new_user

      sign_in(@new_user)
      redirect_to registration_new_account_security_path
    rescue ActiveRecord::RecordInvalid, ActiveRecord::RecordNotFound
      render "confirmation_token_is_invalid"
    end

    def sign_out_before_confirming_email
      sign_out
      redirect_to registration_confirm_submit_user_path(confirmation_token: params[:confirmation_token])
    end

  protected

    # Overwrites Devise::RegistrationsController#after_inactive_sign_up_path_for
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

    def redirect_if_create_an_account_disabled
      unless Flipper.enabled?(:create_an_account)
        redirect_to submit_root_path, alert: "Account creation is currently disabled."
      end
    end
  end
end
