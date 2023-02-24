module Users
  class PasswordsController < Devise::PasswordsController
    skip_before_action :require_no_authentication, only: %i[edit sign_out_before_resetting_password]

    skip_before_action :require_secondary_authentication, except: :update

    def edit
      return render :reset_password_signed_in_as_another_user, locals: { reset_password_token: params[:reset_password_token] } if wrong_user?
      return render :invalid_link, status: :not_found if reset_token_invalid?
      return render :expired, status: :gone if reset_token_expired?

      require_secondary_authentication

      @email = user_with_reset_token.email

      super
    end

    def sign_out_before_resetting_password
      user = current_user
      sign_out

      case user
      when SubmitUser
        redirect_to edit_submit_user_password_path(reset_password_token: params[:reset_password_token])
      when SearchUser
        redirect_to edit_search_user_password_path(reset_password_token: params[:reset_password_token])
      end
    end

    def create
      user = user_class.find_by(email: params[user_param_key][:email])
      return resend_account_setup_link_for(user) if user && !user.has_completed_registration?

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
      user_signed_in? && user_with_reset_token && current_user != user_with_reset_token
    end

    def passed_secondary_authentication?
      UnusedCodeAlerting.alert
      return true unless Rails.configuration.secondary_authentication_enabled

      user_signed_in? && is_fully_authenticated?
    end

    def resend_account_setup_link_for(user)
      user.confirmed_at = nil
      user.account_security_completed = false
      user.save(validate: false)
      # TODO: Remove this branch based on pending invitations once invitations
      # contain user name (pending feature).
      # Once that happens logic can default to resending the account setup link
      # as done with user who registered without an invitation.
      if (invitation = PendingResponsiblePersonUser.where(email_address: user.email).last)
        invitation.refresh_token_expiration!
        SubmitNotifyMailer.send_responsible_person_invite_email(
          invitation.responsible_person, invitation, invitation.inviting_user.name
        ).deliver_later
      else
        user.resend_account_setup_link
      end
      redirect_to check_your_email_path
    end

    def reset_token_invalid?
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
      resource.errors.details[:email].include?(error: :not_found)
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
      password_changed_path
    end

    def user_id_for_secondary_authentication
      token_from_put = Devise.token_generator.digest(user_class, :reset_password_token, params[user_param_key][:reset_password_token]) if request.put?
      user_with_reset_token&.id ||
        User.find_by(reset_password_token: token_from_put)&.id
    end

    def current_operation
      SecondaryAuthentication::Operations::RESET_PASSWORD
    end

    def user_class
      if params.key?("search_user")
        return SearchUser
      elsif params.key?("submit_user")
        return SubmitUser
      end

      raise ArgumentError
    end

    def user_param_key
      user_class.name.underscore.to_sym
    end
  end
end
