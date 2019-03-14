class TeamsController < ApplicationController
  before_action :set_user_teams, only: :index
  before_action :set_team, only: %i[show invite_to]
  before_action :set_new_user, only: :invite_to

  # GET /teams, GET /my-teams
  def index; end

  def show; end

  # GET /teams/:id/invite, PUT /teams/:id
  def invite_to
    if request.put? && @new_user.valid?
      existing_user = User.find_by email: @new_user.email_address
      if existing_user
        if existing_user.organisation == @team.organisation
          @team.add_user existing_user
          NotifyMailer.user_added_to_team(
              name: existing_user.full_name,
              email: existing_user.email,
              team_id: @team.id,
              team_name: @team.name)
        else
          # TODO MSPSDS-1047 Raise better error
          @new_user.errors.add(:email_address, "#{@new_user.email_address.capitalize} belongs to another organisation and connot be added to team #{@team.display_name}")
        end
      else
        raise "not implemented"
        # TODO MSPSDS-1047 Create user in correct group
        # TODO MSPSDS-1047 Send registration email
      end

      # TODO MSPSDS-1047 Show success message
      if @new_user.errors.empty?
        render :show
      else
        render :invite_to
      end
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

end
