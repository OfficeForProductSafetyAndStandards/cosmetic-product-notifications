class InvestigationPolicy < ApplicationPolicy
  def destroy?
    @user.has_role? :admin
  end

  def show?
    @record.visible_to(@user)
  end
end
