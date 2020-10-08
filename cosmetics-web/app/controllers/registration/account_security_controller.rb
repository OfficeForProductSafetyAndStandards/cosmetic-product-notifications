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
      params.require(:registration_account_security_form).permit(:mobile_number, :password, :full_name)
    end

    def after_creation_path
      if (pending_team_invitation = PendingResponsiblePersonUser.find_by(email_address: current_user.email))
        join_responsible_person_team_members_path(pending_team_invitation.responsible_person_id,
                                                  invitation_token: pending_team_invitation.invitation_token)
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
