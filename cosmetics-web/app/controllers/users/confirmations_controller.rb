# frozen_string_literal: true

module Users
  class ConfirmationsController < Devise::ConfirmationsController
    # GET /resource/confirmation?confirmation_token=abcdef
    def show
      if wrong_user?
        render :confirm_email_signed_in_as_another_user, locals: { confirmation_token: params[:confirmation_token] }
      elsif user_with_confirmation_token.confirmed?
        sign_out
        redirect_to new_user_session_path
      else
        super
      end
    end

    def sign_out_before_confirming_email
      sign_out
      redirect_to submit_user_confirmation_path(confirmation_token: params[:confirmation_token])
    end

  private

    def wrong_user?
      user_signed_in? && current_user != user_with_confirmation_token
    end

    def user_with_confirmation_token
      @user_with_confirmation_token ||= User.find_by(confirmation_token: params[:confirmation_token])
    end
  end
end
