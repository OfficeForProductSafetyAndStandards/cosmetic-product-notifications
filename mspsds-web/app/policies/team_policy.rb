class TeamPolicy < ApplicationPolicy
  def show?(user: @user, team: @record)
    user.teams.include? team
  end
end
