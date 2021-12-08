class ResponsiblePersons::InvitationsController < SubmitApplicationController
  before_action :set_responsible_person
  before_action :authorize_responsible_person
  before_action :validate_responsible_person
  before_action :set_invitation

  skip_before_action :create_or_join_responsible_person

  def cancel; end

  def destroy
    case params[:cancel_invitation]
    when "yes"
      @invitation.destroy!
      redirect_to(responsible_person_team_members_path(@responsible_person), confirmation: "The invitation was cancelled")
    when "no"
      redirect_to(responsible_person_team_members_path(@responsible_person))
    else
      @invitation.errors.add(:cancel_invitation, "Select yes if you want to cancel the invitation")
      render :cancel
    end
  end

private

  def set_responsible_person
    @responsible_person = ResponsiblePerson.find(params[:responsible_person_id])
  end

  def set_invitation
    @invitation = @responsible_person.pending_responsible_person_users.find(params[:id])
  end

  def authorize_responsible_person
    authorize @responsible_person, :show?
  end

  # See: SecondaryAuthenticationConcern
  def current_operation
    SecondaryAuthentication::Operations::INVITE_USER
  end
end
