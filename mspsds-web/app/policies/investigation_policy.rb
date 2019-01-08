class InvestigationPolicy < ApplicationPolicy
  include UserService
  def destroy?
    @user.has_role? :admin
  end

  def show?
    @record.visible_to(@user)
  end
end
