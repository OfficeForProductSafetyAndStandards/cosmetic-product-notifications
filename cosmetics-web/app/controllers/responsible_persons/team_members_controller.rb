class ResponsiblePersons::TeamMembersController < ApplicationController
  before_action :set_responsible_person
  before_action :set_team_member, only: %i[new create]
  skip_before_action :create_or_join_responsible_person

  def index; binding.pry; end
  def new; end

  def create
    @responsible_person.save
    if @responsible_person.errors.empty?
      send_invite_email
      redirect_to responsible_person_team_members_path(@responsible_person)
    else
      render :new
    end
  end

  def join
    pending_requests = PendingResponsiblePersonUser.pending_requests_to_join_responsible_person(
      current_user,
      @responsible_person,
    )

    if pending_requests.any?
      @responsible_person.add_user(current_user)
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
    params.fetch(:team_member, {}).permit(
      :email_address,
    )
  end

  def set_team_member
    @team_member = @responsible_person.pending_responsible_person_users.build(team_member_params)
  end

  def send_invite_email
    NotifyMailer.send_responsible_person_invite_email(@responsible_person.id, @responsible_person.name,
                                                      @team_member.email_address, current_user.name).deliver_later
  end
end
