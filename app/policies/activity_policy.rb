class ActivityPolicy < ApplicationPolicy
  def update?
    @record.source.type != "user" || @user.has_role?(:admin) || @user == @record.source.user
  end

  def destroy?
    @record.source.type != "user" || @user.has_role?(:admin) || @user == @record.source.user
  end
end
