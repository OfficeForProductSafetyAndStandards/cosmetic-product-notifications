module Registration
  class NewAccountsController < ApplicationController
    skip_before_action :authorize_user!
    skip_before_action :authenticate_user!
    skip_before_action :require_secondary_authentication

    def new
      @new_account_form = NewAccountForm.new
    end

    def create
      if new_account_form.invalid?
        render :new
      else
        # do stuff
        # redirect to confirmation send
      end
    end

  protected

    def after_inactive_sign_up_path_for(_resource)
      check_your_email_path
    end

  private

    def new_account_form
      @new_account_form ||= NewAccountForm.new(params[:sign_up_form])
    end
  end
end
