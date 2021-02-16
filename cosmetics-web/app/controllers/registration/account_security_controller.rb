module Registration
  class AccountSecurityController < SubmitApplicationController
    before_action :check_user
    skip_before_action :require_secondary_authentication
    skip_before_action :try_to_finish_account_setup

    def new
      @account_security_form = AccountSecurityForm.new(user: current_user)
    end

    def create
      if account_security_form.update!
        bypass_sign_in(current_user)
        # Sets 2FA cookie for users that have set authentication APP in the account security page.
        # If they have chosen the sms code authentication option we won't set the cookie until
        # they confirm their mobile number with the sms code at "Check your phone" page.
        if account_security_form.app_authentication_selected? && !account_security_form.sms_authentication_selected?
          set_secondary_authentication_cookie(Time.zone.now.to_i) if current_user.last_totp_at
        end
        redirect_to after_creation_path
      else
        render :new
      end
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
                    :app_authentication_secret_key,
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
      return unless current_user.account_security_completed

      redirect_to root_path
    end
  end
end
