
class InvestigationPolicy < ApplicationPolicy
  def reopen?
    @user.has_role? :admin
  end

  def update?
    !@record.is_closed?
  end

  def destroy?
    @user.has_role? :admin
  end
end
