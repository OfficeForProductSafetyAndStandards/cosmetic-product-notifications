class TeamsController < ApplicationController
  before_action :set_teams

  def index;
    redirect_to :my_teams
  end

  def my_teams
    render :index
  end

  def set_teams
    @teams = User.current.teams
  end

end
