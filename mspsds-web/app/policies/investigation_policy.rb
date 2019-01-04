class InvestigationPolicy < ApplicationPolicy
  def destroy?
    @user.has_role? :admin
  end

  def show?
    @record.can_be_seen_by_current_user
  end
end
