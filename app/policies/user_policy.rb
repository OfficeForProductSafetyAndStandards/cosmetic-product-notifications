
class UserPolicy < ApplicationPolicy
  def index?
    @user.has_role? :admin
  end

  def invite?
    @user.has_role? :admin
  end

  def show?
    @user.has_role?(:admin) || @user == @record
  end

  def update?
    @user.has_role? :admin
  end

  def destroy?
    return false if @user == @record
    @user.has_role? :admin
  end
end
