class TeamsController < ApplicationController
  before_action :set_user_teams, only: :index
  before_action :set_team, only: %i[show invite_to]
  before_action :set_new_user, only: :invite_to

  # GET /teams, GET /my-teams
  def index; end

  def show; end

  # GET /teams/:id/invite, PUT /teams/:id/invite
  def invite_to
    if request.put? && @new_user.valid?
      existing_user = User.find_by email: @new_user.email_address
      if existing_user
        if existing_user.organisation == @team.organisation
          if @team.users.include? existing_user
            @new_user.errors.add(:email_address, "#{@new_user.email_address.capitalize} is already a member of #{@team.display_name}")
          else
            @team.add_user existing_user
            NotifyMailer.user_added_to_team existing_user.email,
                                            name: existing_user.full_name,
                                            team_id: @team.id,
                                            team_name: @team.name
          end
        else
          # TODO MSPSDS-1047 Raise better error
          @new_user.errors.add(:email_address, "#{@new_user.email_address.capitalize} does not belong to this organisation and connot be added to team #{@team.display_name}.")
        end
      else
        user = User.create_new @new_user.email_address
        @team.add_user user
        Shared::Web::KeycloakClient.instance.send_required_actions_welcome_email user.id, root_url
      end

      # TODO MSPSDS-1047 Show success message
      if @new_user.errors.empty?
        redirect_to @team, status: :see_other
      else
        render :invite_to, status: :bad_request
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
