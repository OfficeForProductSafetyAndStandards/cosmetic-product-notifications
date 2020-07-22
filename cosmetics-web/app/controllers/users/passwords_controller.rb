module Users
  class PasswordsController < Devise::PasswordsController
    # skip_before_action :assert_reset_token_passed,
    #                    :require_no_authentication,
    #                    :has_accepted_declaration,
    #                    :has_viewed_introduction,
    #                    only: %i[edit sign_out_before_resetting_password]

    # skip_before_action :require_secondary_authentication

    # before_action :require_secondary_authentication, only: :update

    def edit
      # return render :signed_in_as_another_user, locals: { reset_password_token: params[:reset_password_token] } if wrong_user?
      return render :invalid_link, status: :not_found if reset_token_invalid?
      return render :expired, status: :gone if reset_token_expired?

      # require_secondary_authentication

      @email = user_with_reset_token.email

      super
    end

    def sign_out_before_resetting_password
      sign_out
      redirect_to edit_user_password_path(reset_password_token: params[:reset_password_token])
    end

    def create
      # user = User.find_by(email: params[:user][:email])
      # return resend_invitation_link_for(user) if user && !user.has_completed_registration?

      super do |resource|
        suppress_email_not_found_error

        if reset_password_form.invalid?
          resource.errors.clear
          resource.errors.merge!(reset_password_form.errors)
          return render :new
        end
      end
    end

    def update
      super do |resource|
        @email = resource.email

        if reset_password_token_just_expired?
          return render :expired
        end
      end
    end

  private

    def wrong_user?
      user_signed_in? && current_user != user_with_reset_token
    end

    def passed_secondary_authentication?
      return true unless Rails.configuration.secondary_authentication_enabled

      user_signed_in? && is_fully_authenticated?
    end

    def resend_invitation_link_for(user)
      SendUserInvitationJob.perform_later(user.id, nil)
      redirect_to check_your_email_path
    end

    def reset_token_invalid?
      # return render :expired, status: :gone if reset_token_expired?
      params[:reset_password_token].blank? || user_with_reset_token.blank?
    end

    def reset_token_expired?
      !user_with_reset_token.reset_password_period_valid?
    end

    def user_with_reset_token
      @user_with_reset_token ||= User.find_by(reset_password_token: hashed_reset_token)
    end

    def hashed_reset_token
      Devise.token_generator.digest(User, :reset_password_token, params[:reset_password_token])
    end

    def suppress_email_not_found_error
      return unless email_not_found_first_error?

      resource.errors.delete(:email)
    end

    def email_not_found_first_error?
      resource.errors.details.dig(:email).include?(error: :not_found)
    end

    def reset_password_form
      @reset_password_form ||= ResetPasswordForm.new(resource_params.permit(:email))
    end

    def reset_password_token_just_expired?
      resource.errors[:reset_password_token].any?
    end

    def after_sending_reset_password_instructions_path_for(_resource_name)
      check_your_email_path
    end

    def after_resetting_password_path_for(_resource)
      binding.pry
      password_changed_path
    end

    def user_id_for_secondary_authentication
      token_from_put = Devise.token_generator.digest(User, :reset_password_token, params[:user][:reset_password_token]) if request.put?
      user_with_reset_token&.id ||
        User.find_by(reset_password_token: token_from_put)&.id
    end

    def current_operation
      SecondaryAuthentication::RESET_PASSWORD_OPERATION
    end
  end
end
