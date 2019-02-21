class ResponsiblePersons::TeamMembersController < ApplicationController
  before_action :set_responsible_person

  def create
    # Check the user entered an email address
    if team_member_params[:email_address].blank?
      return redirect_to new_responsible_person_team_member_path(@responsible_person, blank_input: true)
    end

    # Check if the user is already a member of the team
    if @responsible_person.responsible_person_users.any? { |user| user.email_address == team_member_params[:email_address] }
        return redirect_to new_responsible_person_team_member_path(@responsible_person, user_already_exists: true)
    end

    # If there are pending invitations for this user already, delete them before creating a new one
    PendingResponsiblePersonUser.where(
      responsible_person: @responsible_person, 
      email_address: team_member_params[:email_address]
    ).delete_all

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
