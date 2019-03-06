class TeamsController < ApplicationController
  before_action :set_user_teams, only: :index
  before_action :set_team, only: :show

  def index; end

  def show; end

private

  def set_user_teams
    @teams = User.current.teams
  end

  def set_team
    @team = Team.find_by!(id: params[:id])
    authorize @team
  end
end
