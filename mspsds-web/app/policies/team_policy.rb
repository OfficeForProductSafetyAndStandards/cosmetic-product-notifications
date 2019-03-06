class TeamPolicy < ApplicationPolicy
  def show?(user: @user, team: @record)
    user.teams.include? team
  end

  def invite?(user: @user, team: @record)
    user.teams.include? team && user.is_team_admin?
  end
end
