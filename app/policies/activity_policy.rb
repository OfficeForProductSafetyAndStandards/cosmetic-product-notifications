
class ActivityPolicy < ApplicationPolicy
  def update?
    @user.has_role?(:admin) || @user == @record.user
  end

  def destroy?
    @user.has_role?(:admin) || @user == @record.user
  end
end
