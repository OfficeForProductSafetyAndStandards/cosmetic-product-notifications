module Registration
  class AccountSecurityController < SubmitApplicationController
    before_action :check_user, except: :reset
    skip_before_action :require_secondary_authentication
    skip_before_action :try_to_finish_account_setup

    def new
      # User attributes are only set at this stage when the account security form was previously submitted
      # setting them. Then the user followed the back link from SMS code authentication page to return to
      # the account security page and change the options.
      @account_security_form = AccountSecurityForm.new(
        user: current_user,
        full_name: current_user.name,
        mobile_number: current_user.mobile_number,
        sms_authentication: current_user.secondary_authentication_methods&.include?("sms"),
        app_authentication: current_user.secondary_authentication_methods&.include?("app"),
        secret_key: current_user.totp_secret_key,
      )
    end

    def create
      if account_security_form.update!
        bypass_sign_in(current_user)
        # Sets 2FA cookie for users that have set authentication APP in the account security page.
        # If they have chosen the SMS code authentication option we won't set the cookie until
        # they confirm their mobile number with the sms code at SMS code authentication page.
        if account_security_form.app_authentication_selected? && !account_security_form.sms_authentication_selected?
          set_secondary_authentication_cookie(Time.zone.now.to_i) if current_user.last_totp_at
        end
        redirect_to after_creation_path
      else
        render :new
      end
    end

    # Needed to re-display the account security form for an user that has submitted it but needs to go back.
    # Filter "#check_user" impedes users who completed account security to directly visit "#new" action.
    # This route allows that to happen in specific situations where we need to.
    # EG: Navigating back from the SMS code authentication page after selecting SMS as one of the 2FA methods.
    def reset
      current_user.update(account_security_completed: false)
      redirect_to registration_new_account_security_path
    end

  private

    def account_security_form
      @account_security_form ||= AccountSecurityForm.new(account_security_form_params.merge(user: current_user))
    end

    def account_security_form_params
      params.require(:registration_account_security_form)
            .permit(:mobile_number,
                    :password,
                    :full_name,
                    :secret_key,
                    :app_authentication_code,
                    :sms_authentication,
                    :app_authentication)
    end

    def after_creation_path
      invitation_id = session.delete(:registered_from_responsible_person_invitation_id)
      if (invitation = PendingResponsiblePersonUser.find_by(id: invitation_id))
        join_responsible_person_team_members_path(invitation.responsible_person_id,
                                                  invitation_token: invitation.invitation_token)
      elsif pending_invitations.any?
        account_path(:pending_invitations)
      else
        declaration_path
      end
    end

    def check_user
      return (redirect_to root_path) if current_user.account_security_completed
    end
  end
end
