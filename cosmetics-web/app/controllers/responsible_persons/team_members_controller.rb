class ResponsiblePersons::TeamMembersController < ApplicationController
  before_action :set_responsible_person
  skip_before_action :create_or_join_responsible_person

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
      responsible_person_id: @responsible_person.id, 
      email_address: team_member_params[:email_address]
    ).delete_all

    pending_responsible_person_user = PendingResponsiblePersonUser.create(team_member_params)
    pending_responsible_person_user.update responsible_person: @responsible_person
    redirect_to responsible_person_team_members_path(@responsible_person)
  end

  def join
    pending_responsible_person_user = PendingResponsiblePersonUser.where(
      "email_address = ? AND key = ? AND responsible_person_id = ? AND expires_at > ?",
      User.current.email,
      params[:key],
      params[:responsible_person_id],
      DateTime.current)  

    if pending_responsible_person_user.any?
      @responsible_person.add_user(User.current)
      @responsible_person.save
      pending_responsible_person_user.delete_all
    end

    redirect_to responsible_person_path(@responsible_person)
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
