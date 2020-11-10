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
