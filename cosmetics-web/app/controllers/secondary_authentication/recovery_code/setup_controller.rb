module SecondaryAuthentication
  class RecoveryCode
    class SetupController < ApplicationController
      def new
        @user = current_user
        return redirect_to(root_path) unless @user

        # Generate new recovery codes
        # Don't regenerate recovery codes if they have already been generated once.
        # Recovery codes can only be regenerated after initial setup by manually
        # running either `@user.reset_secondary_authentication!` or
        # `GenerateRecoveryCodes.call(user: @user)`.
        GenerateRecoveryCodes.call(user: @user) if @user.secondary_authentication_recovery_codes_generated_at.nil?

        @recovery_codes = @user.secondary_authentication_recovery_codes
        @recovery_codes_used = @user.secondary_authentication_recovery_codes_used
        @continue_path = continue_path
      end

    private

      def continue_path
        return my_account_path if params[:back_to] == "my_account"

        invitation_id = session.delete(:registered_from_responsible_person_invitation_id)
        if (invitation = PendingResponsiblePersonUser.find_by(id: invitation_id))
          join_responsible_person_team_members_path(invitation.responsible_person_id,
                                                    invitation_token: invitation.invitation_token)
        elsif pending_invitations.any?
          account_path(:pending_invitations)
        elsif current_user.is_a?(SupportUser)
          root_path
        else
          declaration_path
        end
      end

      def pending_invitations
        @pending_invitations ||= PendingResponsiblePersonUser
          .where(email_address: current_user.email)
          .includes(:responsible_person, :inviting_user)
          .order(created_at: :desc)
      end
    end
  end
end
