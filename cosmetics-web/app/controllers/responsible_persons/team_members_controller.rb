class ResponsiblePersons::TeamMembersController < ApplicationController
  before_action :set_responsible_person

  def create
    pending_responsible_person_user = PendingResponsiblePersonUser.create(team_member_params)
    pending_responsible_person_user.update responsible_person: @responsible_person
    redirect_to responsible_person_team_members_path(@responsible_person)
  end

private

  def set_responsible_person
    @responsible_person = ResponsiblePerson.find(params[:responsible_person_id])
    authorize @responsible_person, :show?
  end

  def team_member_params
    params.require(:team_member)
      .permit(
        :email_address
      )
  end
end
