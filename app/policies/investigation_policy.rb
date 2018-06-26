
class InvestigationPolicy < ApplicationPolicy
  def reopen?
    @user.has_role? :admin
  end

  def destroy?
    @user.has_role? :admin
  end
end
