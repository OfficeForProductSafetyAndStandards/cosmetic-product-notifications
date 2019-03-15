class TeamsController < ApplicationController
  before_action :set_user_teams, only: :index
  before_action :set_team, only: %i[show invite_to]
  before_action :set_new_user, only: :invite_to

  # GET /teams, GET /my-teams
  def index; end

  def show; end

  # GET /teams/:id/invite, PUT /teams/:id/invite
  def invite_to
    return unless request.put? && @new_user.valid?

    existing_user = User.find_by email: @new_user.email_address
    if existing_user
      invite_existing_user_if_able existing_user
    else
      create_and_invite_new_user
    end

    if @new_user.errors.empty?
      flash[:notice] = "Invite sent to #{@new_user.email_address}"
      redirect_to @team, status: :see_other
    else
      render :invite_to, status: :bad_request
    end
  end

private

  def set_user_teams
    @teams = User.current.teams
  end

  def set_team
    @team = Team.find_by!(id: params[:id])
    authorize @team
  end

  def set_new_user
    @new_user = NewUser.new params[:new_user]&.permit(:email_address)
  end

  def invite_existing_user_if_able(user)
    if user.organisation.present? && user.organisation != @team.organisation
      @new_user.errors.add(:email_address, :member_of_another_organisation)
      return
    end
    if @team.users.include? user
      @new_user.errors.add(:email_address,
                           "#{@new_user.email_address.capitalize} is already a member of #{@team.display_name}")
      return
    end
    invite_user user
  end

  def invite_user(user)
    @team.add_user user
    email = NotifyMailer.user_added_to_team user.email,
                                            name: user.full_name,
                                            team_page_url: team_url(@team),
                                            team_name: @team.name,
                                            service_name: "Product safety database",
                                            inviting_team_member_name: User.current.full_name
    email.deliver_later
  end

  def create_and_invite_new_user
    user = User.create_new @new_user.email_address
    @team.add_user user
    Shared::Web::KeycloakClient.instance.send_required_actions_welcome_email user.id, root_url
  end
end
