class TeamsController < ApplicationController
  before_action :set_user_teams, only: :index
  before_action :set_team, only: %i[show invite]
  before_action :set_new_user, only: :invite

  # GET /teams, GET /my-teams
  def index; end

  def show; end

  # GET, PUT /teams/:id/invite
  def invite
    if request.put? && @new_user.valid?
      existing_user = User.find_by email_address: @new_user.email_address
      if existing_user
        if existing_user.organisation == @team.organisation
          # TODO MSPSDS-1047 Add to team
          # TODO MSPSDS-1047 Send email to
        else
          # TODO MSPSDS-1047 Raise better error
          @new_user.errors.add(:email_address, "#{@new_user.email_address.capitalize} belongs to another organisation and connot be added to team #{@team.display_name}")
        end
      else
        # TODO MSPSDS-1047 Create user in correct group
        # TODO MSPSDS-1047 Send registration email
      end

      # TODO MSPSDS-1047 Show success message
      redirect_to :team
    end
  end

private

  def set_user_teams
    @teams = User.current.teams
  end

  def set_team
    @team = Team.find_by!(id: params[:id])
    authorize @team, :show?
  end

  def set_new_user
    @new_user = NewUser.new params[:new_user]&.permit(:email_address)
  end

end
