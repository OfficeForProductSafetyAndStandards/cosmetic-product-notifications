class ResponsiblePersons::TeamMembersController < ApplicationController
  before_action :set_responsible_person
  before_action :set_team_member, only: %i[new create]
  skip_before_action :create_or_join_responsible_person

  def new; end

  def create
    if responsible_person_saved?
      NotifyMailer.send_responsible_person_invite_email(@responsible_person.id, @responsible_person.name,
                                                        @team_member.email_address, User.current.name).deliver_later
      redirect_to responsible_person_team_members_path(@responsible_person)
    else
      render :new
    end
  end

  def join
    pending_requests = PendingResponsiblePersonUser.pending_requests_to_join_responsible_person(
      User.current,
        @responsible_person
    )

    if pending_requests.any?
      @responsible_person.add_user(User.current)
      Rails.logger.info "Team member added to Responsible Person"
      pending_requests.delete_all
    end

    redirect_to responsible_person_path(@responsible_person)
  end

private

  def set_responsible_person
    @responsible_person = ResponsiblePerson.find(params[:responsible_person_id])
    authorize @responsible_person, :show?
  end

  def team_member_params
    team_member_session_params.merge(team_member_request_params)
  end

  def team_member_session_params
    session.fetch(:team_member, {})
  end

  def team_member_request_params
    params.fetch(:team_member, {}).permit(
      :email_address
    )
  end

  def set_team_member
    @team_member = @responsible_person.pending_responsible_person_users.build(team_member_params)
  end

  def responsible_person_saved?
    return false unless responsible_person_valid?

    @responsible_person.save
  end

  def responsible_person_valid?
    @responsible_person.valid?
  end
end
