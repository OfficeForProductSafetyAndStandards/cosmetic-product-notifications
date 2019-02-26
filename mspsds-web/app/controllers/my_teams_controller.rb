class MyTeamsController < ApplicationController
  before_action :set_teams

  def show; end

  def set_teams
    @teams = User.current.teams
  end

end
