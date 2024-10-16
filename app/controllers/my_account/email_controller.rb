module MyAccount
  class EmailController < ApplicationController
    before_action :allow_only_submit_support_domains

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
      if e.record.errors.where(:new_email, :taken).any?
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

    def allow_only_submit_support_domains
      raise "Not a submit or support domain" unless submit_domain? || support_domain?
    end

    def authorize_user!
      redirect_to invalid_account_path if current_user && current_user.is_a?(SearchUser)
    end
  end
end
