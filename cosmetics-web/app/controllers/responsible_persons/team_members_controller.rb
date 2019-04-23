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

    NotifyMailer.send_responsible_person_invite_email(@responsible_person.id, @responsible_person.name, team_member_params[:email_address], User.current.name).deliver_later
    redirect_to responsible_person_team_members_path(@responsible_person)
  end

  def join
    pending_responsible_person_user = PendingResponsiblePersonUser.where(
      "email_address = ? AND responsible_person_id = ? AND expires_at > ?",
      User.current.email,
      params[:responsible_person_id],
      DateTime.current
)

    if pending_responsible_person_user.any?
      @responsible_person.add_user(User.current)
      Rails.logger.info "Team member added to Responsible Person"
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
