class InvestigationPolicy < ApplicationPolicy
  include UserService
  def destroy?
    @user.has_role? :admin
  end

  def show?
    @record.visible_to(current_user)
  end
end
