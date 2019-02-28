class TeamsController < ApplicationController
  before_action :set_my_teams, only: :my_teams
  before_action :set_team , only: :show

  def index
    redirect_to :my_teams
  end

  def my_teams
    render :index
  end

  def show
  end

private

  def set_my_teams
    @teams = User.current.teams
  end

  def set_team
    @team = Team.find(params[:id])
  end

end
