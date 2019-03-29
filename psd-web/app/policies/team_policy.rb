class TeamPolicy < ApplicationPolicy
  def show?(user: @user, team: @record)
    user.teams.include? team
  end

  def invite_to?(user: @user, team: @record)
    user.is_team_admin? && (user.teams.include? team)
  end
end
