module Registration
  class AccountSecurityController < SubmitApplicationController
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
      params.require(:registration_account_security_form).permit(:mobile_number, :password)
    end

    def after_creation_path
      # TODO: Do we need this check? This controller only seems accessible for Submit users.
      return declaration_path unless current_user.is_a?(SubmitUser)

      if (pending_invitation = PendingResponsiblePersonUser.where(email_address: current_user.email).last)
        join_responsible_person_team_member_path(pending_invitation.responsible_person, pending_invitation)
      else
        declaration_path
      end
    end
  end
end
